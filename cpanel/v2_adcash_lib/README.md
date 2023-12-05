# Integrate Adcash Adblock Library

1. Download [Adcash script - adblock.sh](https://raw.githubusercontent.com/adcash/customer-scripts/master/cpanel/v2_adcash_lib/adblock.sh)
2. Upload it into your public directory on Cpanel
3. Open terminal from Cpanel
4. Go to your public directory `cd ~/public_html`
5. Execute the script to create the tag for the Adcash library `bash adblock.sh add`
6. Copy the generated code (`<script type="text/javascript" src="/adc-ads-lib"></script>`) and paste it in the head section of the page you want to show the Ad
7. Anywhere beneath this script, create a new script tag that will utilise the library
i.e. for running a Pop zone with zone id = '1234567':

```
<script>
    aclib.runPop({ zoneId: '1234567' });
</script>
```

Example for running AutoTag zone with zone id = 'ab1cdefg23':

```
<script>
    aclib.runAutoTag({ zoneId: 'ab1cdefg23' });
</script>
```

## To uninstall:
1. Execute the script with `uninstall` option: `bash adblock.sh uninstall`
2. Remove the tag (`<script type="text/javascript" src="/adc-ads-lib"></script>`) from the head section of all  the page, that was showing the Ad
3. Remove the script beneath the library that utilises it

