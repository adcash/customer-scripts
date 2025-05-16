# Ads integration with WPCode

This guide was tested with the following versions:

- WordPress: 6.8.1
- WPCode Plugin: 2.2.7

> **Note:** ⚠️ If you're using a different version, some settings or features may appear differently.

1. Install the [WPCode](https://wordpress.org/plugins/insert-headers-and-footers/) plugin and enable it
2. Click `Code Snippets` → `Add New` → `Add your Custom Code`
3. Select the code type for your snippet:

   1. Select `HTML Snippet` if you want to integrate standard ads

      Paste the following HTML snippets in the editor

      > **Note:** If you already have Adcash lib included, it is unnecessary to include it again

      ```html
      <script id="aclib" type="text/javascript" src="//acscdn.com/script/aclib.js"></script>
      ```

      > **Note:** Just make sure you replace **DESIRED_FORMAT_HERE** (e.g., `Pop`, `InPagePush`, `Banner`, `Interstitial`, `AutoTag`, `VideoSlider`) and **ZONE_ID_HERE** with the required ones.

      ```html
      <script type="text/javascript">
        aclib.runDESIRED_FORMAT_HERE({
          zoneId: 'ZONE_ID_HERE',
        });
      </script>
      ```

      Example for Banner ad:

      > **Note:** If you want to render the banner ad inside a specific element, you need to pass the `renderIn` property, which should be the `querySelector` of the target element. Otherwise, by default, it will be rendered inside its own parent element.

      ```html
      <script type="text/javascript">
        aclib.runBanner({
          zoneId: '9999999',
          renderIn: '#target-element',
        });
      </script>
      ```

   2. Select `PHP Snippet` if you prefer to use our adblock solution

      Paste the following PHP snippet in the editor

      > **Note:** Just make sure you replace **DESIRED_FORMAT_HERE** (e.g., `Pop`, `InPagePush`, `Banner`, `Interstitial`, `AutoTag`, `VideoSlider`) and **ZONE_ID_HERE** with the required ones.

      ```php
        function enqueue_adcash_anti_adblock_lib_script() {
          $cache_key = 'adcash_anti_adblock_lib_script';
          $cache_timeout = 5 * MINUTE_IN_SECONDS;

          // check if already in temporary cache in db
          $script_content = get_transient($cache_key);

         if ($script_content === false) {
           $response = wp_remote_get('https://adbpage.com/adblock?v=3&format=js');
            if (is_wp_error($response) || wp_remote_retrieve_response_code($response) !== 200) {
             error_log('Failed to fetch adcash anti-adblock library script.');
             return;
            }

           $script_content = wp_remote_retrieve_body($response);
           set_transient($cache_key, $script_content, $cache_timeout);
         }

          // register and add inline script to head
          wp_register_script('acsh-anti-abl-lib-script', false, [], null, false);

          // attach script content to newly created handle
          wp_add_inline_script('acsh-anti-abl-lib-script', $script_content);

          // enqueues for loading. manages dependencies
          wp_enqueue_script('acsh-anti-abl-lib-script');
        }

        add_action('wp_enqueue_scripts', 'enqueue_adcash_anti_adblock_lib_script');

        function enqueue_adcash_anti_adblock_aclib_ad_init_script() {
         // add dependent on library initialization script to footer
         wp_register_script('acsh-anti-abl-lib-ad-init-script', false, ['acsh-anti-abl-lib-script'], null, true);
         wp_add_inline_script('acsh-anti-abl-lib-ad-init-script', 'if (window.aclib) { aclib.runDESIRED_FORMAT_HERE({ zoneId: "ZONE_ID_HERE" }); }');
         wp_enqueue_script('acsh-anti-abl-lib-ad-init-script');
        }

        add_action('wp_enqueue_scripts', 'enqueue_adcash_anti_adblock_aclib_ad_init_script');
      ```

4. Click `Save`, then activate the snippet. That's it-you're done!
