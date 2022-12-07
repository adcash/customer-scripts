# Integrate Adcash Adblock POP/Autotag

1. Download [Adcash script - adblock.sh](https://github.com/adcash/customer-scripts/blob/master/cpanel/adblock.sh)
2. Upload it into your public directory on Cpanel
3. Open terminal from Cpanel
4. Go to your public directory `cd ~/public_html`
5. Execute the script to create the tag for your Adcash zone `bash adblock.sh add [suv4|atag] [ZONE_ID]` where `suv4` is added for a pop tag and `atag` for autotag. [ZONE_ID] should be replaced with the id of your zone, found in Adcash panel
6. Copy the generated code, that looks like this `<script type="text/javascript" src="/z-12345"></script>` and paste it in the head section of the page you want to show the Ad

## To uninstall:
1. Execute the script with `remove` option and the tag for your Adcash zone `bash adblock.sh remove [suv4|atag] [ZONE_ID]` where `suv4` is added for a pop tag and `atag` for autotag. [ZONE_ID] 
2. Remove the tag, that looks like this `<script type="text/javascript" src="/z-12345"></script>` from the head section of the page, that was showing the Ad
