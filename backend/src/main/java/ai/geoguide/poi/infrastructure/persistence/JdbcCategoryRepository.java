package ai.geoguide.poi.infrastructure.persistence;

import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.poi.domain.Category;
import java.util.List;
import java.util.Optional;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class JdbcCategoryRepository implements CategoryRepository {

    private final JdbcTemplate jdbcTemplate;

    public JdbcCategoryRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Category save(Category category) {
        jdbcTemplate.update("""
                INSERT INTO geo.category (id, code, name, active)
                VALUES (?, ?, ?, ?)
                ON CONFLICT (code) DO UPDATE
                SET name = EXCLUDED.name, active = EXCLUDED.active
                """, category.id(), category.code(), category.name(), category.active());
        return category;
    }

    @Override
    public Optional<Category> findByCode(String code) {
        List<Category> results = jdbcTemplate.query("""
                SELECT id, code, name, active FROM geo.category WHERE code = ?
                """, (rs, rowNum) -> new Category(
                        rs.getObject("id", java.util.UUID.class),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getBoolean("active")), code);
        return results.stream().findFirst();
    }
}
