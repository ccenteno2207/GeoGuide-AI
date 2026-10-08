# P12 Multi-Corridor Technical Discovery

DATE = 2026-10-07
BASELINE = 699302f78bc29f0222adfc9885ae7709d7801678
P12_CONTRACT_BASELINE = 1a814b8339d905d87363f553856a42136004dad9

## Method and coordinates

Read-only sources were the P12 contract, P12.0/P12.2 evidence, P3 seed lima-obrajillo-v1.json, P3 README, Route Discovery implementation and the deployed HTTPS API. Coordinates for Centro Lima (-12.0438016,-77.0300475), Miraflores (-12.1214980,-77.0259064), Lunahuaná (-13.0124859,-76.0993736) and Pachacámac (-12.1495352,-76.7912832) came from Nominatim/OpenStreetMap lookup on 2026-10-07. Canta (-11.4669625,-76.6247746) and Obrajillo (-11.4538209,-76.6201906) came from the curated P3 dataset. No code, data, VM or GraphHopper configuration changed.

The API accepts origin and destination only. It has no waypoint field; corridor 04 was tested as Lima-Canta and Canta-Obrajillo segments.

## Results

| Corridor | Route | Distance m | Duration s | Geometry | POIs | Result |
|---|---|---:|---:|---|---:|---|
| C01 Centro Lima-Miraflores | HTTP 200 | 10168.681 | 758.111 | LineString | 0 | ROUTE_PASS_NO_POI_COVERAGE |
| C02 Centro Lima-Lunahuaná | HTTP 404 NO_ROUTE_FOUND | - | - | - | 0 | NO_ROUTE_FOUND |
| C03 Centro Lima-Pachacámac | HTTP 200 | 36819.350 | 3294.842 | LineString | 0 | ROUTE_PASS_NO_POI_COVERAGE |
| C04A Centro Lima-Canta | HTTP 200 | 101630.376 | 6422.443 | LineString | 5 | ROUTE_AND_POI_PASS |
| C04B Canta-Obrajillo | HTTP 200 | 2547.746 | 305.730 | LineString | 3 | ROUTE_AND_POI_PASS |

Durations are GraphHopper estimates, not real driving times. C02 returned code NO_ROUTE_FOUND and was not replaced by an estimated route.

## POI inventory

C04A returned: 02000000-0000-0000-0000-000000000003 Plaza de Armas de Canta MONUMENT, 23.616 m; 02000000-0000-0000-0000-000000000001 Santuario de Santa Rosa de Quives HISTORIC_CHURCH, 130.648 m; 02000000-0000-0000-0000-000000000002 Petroglifos de Checta ARCHAEOLOGICAL_SITE, 159.093 m; 02000000-0000-0000-0000-000000000005 Iglesia San Juan Bautista de Obrajillo HISTORIC_CHURCH, 1554.281 m; 02000000-0000-0000-0000-000000000004 Plaza de Armas de Obrajillo MONUMENT, 1558.225 m.

C04B returned: 02000000-0000-0000-0000-000000000004 Plaza de Armas de Obrajillo MONUMENT, 20.352 m; 02000000-0000-0000-0000-000000000003 Plaza de Armas de Canta MONUMENT, 23.616 m; 02000000-0000-0000-0000-000000000005 Iglesia San Juan Bautista de Obrajillo HISTORIC_CHURCH, 52.384 m.

C01 and C03 returned zero results. This proves absence from the current Route Discovery result, not absence from the real world. C02 had no valid route, so discovery was not applicable. C04A/C04B overlap is expected from independent segment queries; stable IDs show no duplicate records.

## Coverage and recommendation

C04 is the only candidate with demonstrated route and POI coverage. C01 and C03 are routable but have no current POI coverage. C02 is not routable for the selected endpoints. No dataset expansion is recommended inside frozen P12; new POIs or route changes require a new decision.

DISCOVERY_AC_01 = PASS
DISCOVERY_AC_02 = PASS
DISCOVERY_AC_03 = PASS
DISCOVERY_AC_04 = PASS
DISCOVERY_AC_05 = PASS
DISCOVERY_AC_06 = PASS
DISCOVERY_AC_07 = PASS

P12 scope is unchanged. Device and field gates remain preserved; no driving, tracking, audio or new functionality was initiated.
