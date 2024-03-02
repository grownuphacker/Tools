<?php
// Define the function to randomly display and redirect based on CSV data
function random_redirect($omit_nsfw = false) {
    // Fetch CSV data from GitHub
    $csv_url = 'https://raw.githubusercontent.com/BlueTeamNinja/Tools/master/Troll-o-matic/trollurl.csv'; // Update with your CSV URL
    $csv_data = file_get_contents($csv_url);

    // Parse CSV data
    $lines = explode(PHP_EOL, $csv_data);
    $csv = array_map('str_getcsv', $lines);
    $header = array_shift($csv);

    // Initialize arrays to store names and URLs
    $names = array();
    $urls = array();

    // Filter NSFW results if omit_nsfw is true
    foreach ($csv as $row) {
        if ($omit_nsfw && strtolower($row[2]) === 'nsfw') {
            continue;
        }
        $names[] = $row[0];
        $urls[] = $row[1];
    }

    // Randomly select 20 names
    $selected_names = array_rand($names, 20);

    // Convert selected names to JSON for JavaScript
    $selected_names_json = json_encode($selected_names);

    // Randomly select one name from the selected names
    $random_name_index = array_rand($selected_names);
    $selected_name = $names[$selected_names[$random_name_index]];

    // Find the corresponding URL for the selected name
    $selected_url = $urls[array_search($selected_name, $names)];

    // Output JavaScript for text animation
    ?>
    <script type="text/javascript">
        // Function to display names in rapid succession
        function displayNames(names, index) {
            if (index < names.length) {
                document.getElementById('nameDisplay').innerHTML = names[index];
                setTimeout(function() {
                    displayNames(names, index + 1);
                }, 200); // Adjust the speed of animation here (in milliseconds)
            } else {
                // After displaying all names, redirect to the selected URL
                window.location.href = '<?php echo $selected_url; ?>';
            }
        }

        // Start the animation when the page loads
        window.onload = function() {
            var names = <?php echo $selected_names_json; ?>;
            displayNames(names, 0);
        };
    </script>
    <?php
    // Output HTML element to display names
    echo '<div id="nameDisplay" style="font-size: 24px;"></div>';
}

// Usage:
// To include NSFW results, call the function without passing any parameters:
// random_redirect();

// To omit NSFW results, call the function with true as parameter:
// random_redirect(true);
?>
