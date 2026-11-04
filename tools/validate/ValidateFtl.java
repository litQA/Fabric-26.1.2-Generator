import freemarker.cache.FileTemplateLoader;
import freemarker.cache.MultiTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;

import java.io.File;
import java.io.StringReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Parses every FreeMarker template with the MCreator 2026.3 FreeMarker version and
 * resolves includes against the main generator and the embedded base layers.
 */
public final class ValidateFtl {
    private ValidateFtl() {
    }

    public static void main(String[] args) throws Exception {
        List<File> roots = new ArrayList<>();
        List<FileTemplateLoader> loaders = new ArrayList<>();

        for (String arg : args) {
            File root = new File(arg);
            roots.add(root);
            if (root.isDirectory())
                loaders.add(new FileTemplateLoader(root));
        }

        Configuration configuration = new Configuration(Configuration.VERSION_2_3_35);
        configuration.setTemplateLoader(new MultiTemplateLoader(loaders.toArray(new FileTemplateLoader[0])));
        configuration.setDefaultEncoding("UTF-8");
        configuration.setNumberFormat("computer");
        configuration.setLogTemplateExceptions(false);
        configuration.setWrapUncheckedExceptions(true);

        List<String> errors = new ArrayList<>();
        int count = 0;

        for (File root : roots) {
            if (!root.isDirectory())
                continue;

            try (Stream<Path> stream = Files.walk(root.toPath())) {
                for (Path path : stream.filter(Files::isRegularFile)
                        .filter(path -> path.toString().endsWith(".ftl"))
                        .collect(Collectors.toList())) {
                    count++;
                    String name = root.toPath().relativize(path).toString().replace('\\', '/');
                    try {
                        new Template(name, new StringReader(Files.readString(path)), configuration);
                    } catch (Throwable throwable) {
                        errors.add(path + " :: " + throwable.getClass().getSimpleName() + ": " + throwable.getMessage());
                    }
                }
            }
        }

        System.out.println("FTL files: " + count + ", errors: " + errors.size());
        for (String error : errors)
            System.out.println("ERROR " + error);
        if (!errors.isEmpty())
            System.exit(1);
    }
}
