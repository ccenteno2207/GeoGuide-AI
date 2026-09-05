package ai.geoguide.poi.application.port;

import ai.geoguide.poi.domain.Category;
import java.util.Optional;

public interface CategoryRepository {

    Category save(Category category);

    Optional<Category> findByCode(String code);
}
