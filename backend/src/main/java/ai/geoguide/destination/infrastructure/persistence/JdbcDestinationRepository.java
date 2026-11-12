package ai.geoguide.destination.infrastructure.persistence;

import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class JdbcDestinationRepository implements DestinationRepository {
    private final JdbcTemplate jdbc;
    public JdbcDestinationRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Override
    public List<Destination> search(String query, int limit) {
        return jdbc.query("""
                SELECT d.id, d.canonical_name, d.destination_type, d.administrative_context,
                       ST_Y(d.location) AS latitude, ST_X(d.location) AS longitude,
                       d.source_system, d.source_record_id, d.source_url, d.source_license, d.attribution
                FROM geo.destination d
                WHERE d.active = TRUE AND (d.normalized_name LIKE ? ESCAPE '!'
                    OR EXISTS (SELECT 1 FROM geo.destination_alias a
                               WHERE a.destination_id = d.id AND a.normalized_alias LIKE ? ESCAPE '!'))
                ORDER BY CASE WHEN d.normalized_name = ? OR EXISTS (SELECT 1 FROM geo.destination_alias a
                                                                      WHERE a.destination_id = d.id AND a.normalized_alias = ?) THEN 0
                              WHEN d.normalized_name LIKE ? ESCAPE '!' OR EXISTS (SELECT 1 FROM geo.destination_alias a
                                                                                   WHERE a.destination_id = d.id AND a.normalized_alias LIKE ? ESCAPE '!') THEN 1
                              ELSE 2 END,
                         d.normalized_name, d.administrative_context, d.id
                LIMIT ?
                """, JdbcDestinationRepository::map, contains(query), contains(query), query, query,
                escapeLike(query) + "%", escapeLike(query) + "%", limit);
    }

    @Override
    @Transactional
    public void saveCatalogEntry(Destination d, String version, LocalDate verifiedAt) {
        jdbc.update("""
                INSERT INTO geo.destination(id, canonical_name, normalized_name, destination_type, administrative_context,
                  location, source_system, source_record_id, source_url, source_license, attribution, verified_at, catalog_version)
                VALUES (?, ?, ?, ?, ?, ST_SetSRID(ST_MakePoint(?, ?), 4326), ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (source_system, source_record_id) DO UPDATE SET
                  canonical_name=EXCLUDED.canonical_name, normalized_name=EXCLUDED.normalized_name,
                  destination_type=EXCLUDED.destination_type, administrative_context=EXCLUDED.administrative_context,
                  location=EXCLUDED.location, source_url=EXCLUDED.source_url, source_license=EXCLUDED.source_license,
                  attribution=EXCLUDED.attribution, verified_at=EXCLUDED.verified_at, catalog_version=EXCLUDED.catalog_version,
                  active=TRUE
                """, d.id(), d.canonicalName(), d.normalizedName(), d.type(), d.administrativeContext(),
                d.longitude(), d.latitude(), d.sourceSystem(), d.sourceRecordId(), d.sourceUrl(), d.license(),
                d.attribution(), verifiedAt, version);
        UUID destinationId = jdbc.queryForObject("SELECT id FROM geo.destination WHERE source_system=? AND source_record_id=?",
                UUID.class, d.sourceSystem(), d.sourceRecordId());
        jdbc.update("DELETE FROM geo.destination_alias WHERE destination_id = ?", destinationId);
        for (Destination.Alias alias : d.aliases()) {
            jdbc.update("INSERT INTO geo.destination_alias(id, destination_id, alias, normalized_alias, source_reference) VALUES (?, ?, ?, ?, ?)",
                    alias.id(), destinationId, alias.value(), alias.normalizedValue(), alias.sourceReference());
        }
    }

    private static Destination map(ResultSet rs, int row) throws SQLException {
        return new Destination(rs.getObject("id", UUID.class), rs.getString("canonical_name"), null,
                rs.getString("destination_type"), rs.getString("administrative_context"),
                rs.getDouble("latitude"), rs.getDouble("longitude"), rs.getString("source_system"),
                rs.getString("source_record_id"), rs.getString("source_url"), rs.getString("source_license"),
                rs.getString("attribution"), List.of());
    }
    private static String contains(String query) { return "%" + escapeLike(query) + "%"; }
    private static String escapeLike(String query) { return query.replace("!", "!!").replace("%", "!%").replace("_", "!_"); }
}
