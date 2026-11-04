import org.snakeyaml.engine.v2.api.Load;
import org.snakeyaml.engine.v2.api.LoadSettings;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Parses every YAML document in the supplied roots with the same SnakeYAML Engine
 * version that MCreator 2026.3 uses.
 */
public final class ValidateYaml {
    private ValidateYaml() {
    }

    public static void main(String[] args) throws Exception {
        LoadSettings settings = LoadSettings.builder().setAllowDuplicateKeys(false).build();
        Load load = new Load(settings);
        List<String> errors = new ArrayList<>();
        int count = 0;

        for (String arg : args) {
            Path root = Paths.get(arg);
            if (!Files.isDirectory(root))
                continue;

            try (Stream<Path> stream = Files.walk(root)) {
                for (Path path : stream.filter(Files::isRegularFile)
                        .filter(path -> path.toString().endsWith(".yaml"))
                        .collect(Collectors.toList())) {
                    count++;
                    try {
                        load.loadAllFromString(Files.readString(path));
                    } catch (Exception exception) {
                        errors.add(path + " :: " + exception.getClass().getSimpleName() + ": " + exception.getMessage());
                    }
                }
            }
        }

        System.out.println("YAML files: " + count + ", errors: " + errors.size());
        for (String error : errors)
            System.out.println("ERROR " + error);
        if (!errors.isEmpty())
            System.exit(1);
    }
}
