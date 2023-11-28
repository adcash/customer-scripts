# Integrate Adcash Adblock Library

## Install plugin
1. Download adblock.zip
2. Go to your Wordpress Admin panel
3. Click on 'Plugins' menu
4. Click on 'Upload Plugin' button
5. Select your downloaded adblock.zip
6. Click 'Install'
7. Click 'Activate Plugin'
8. Go to 'Settings' menu in Wordpress and you will see a new item 'Adcash Adblock' - click on it
9. On the Options page set the 'Cache period in minutes' period of the library source.
We recommend to keep the default value of 60.
10. Click on 'Save changes'. 
11. Done! This will add adblock library on all your pages.

## Run ads on a single page
1. Go to Wordpress Admin panel -> Pages and select the desired page
2. Click on the Toggle Block Inserter and add a Custom HTML block
3. Inside the block, i.e. to run a pop ad with zone '1234567', use the following code:

```
<script>
    aclib.runPop({ zoneId: '1234567' });
</script>
```
4. Click Update


## Run ads on all pages
1. Go to Wordpress Admin panel -> Tools -> Theme File Editor
2. Find the part with <header/> i.e. parts -> header.html and click on it
Inside the wrapper element, i.e. to run a pop ad with zone '1234567', use the following code:

```
<script>
    aclib.runPop({ zoneId: '1234567' });
</script>
```
4. Click Update File

## Uninstall plugin:
1. Go to 'Plugins' menu
2. Click 'Deactivate' - this will stop your tag from working but will keep your settings if you activate it later
3. Click 'Delete' to completely remove the plugin and settings
4. Remove your script tags that utilise aclib from your page(s)
