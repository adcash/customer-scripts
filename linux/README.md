# Integrate Adcash Adblock for Linux

## Prerequisites
- admin access to your websites host (server)
- curl installed
- crontab installed

## Upload setup script to your server
1. Download [adblock.sh](https://raw.githubusercontent.com/adcash/customer-scripts/master/linux/adblock.sh)
2. Upload it to your server and make sure you don't make the file public
3. Through terminal make the file executable by running:

       $ chmod +x adblock.sh

4. Before using the script, please check it's manual. To obtain it, run:

       $ ./adblock.sh --help

## Install
1. Find your website's public directory or the directory where you want to download our javascript library file 

   (For example, if you are running a nginx server, the default public folder usually is `/var/www/html/`)
2. In order to install, use the `--install` option. Syntax:

       $ ./adblock.sh --install <path_to_directory> <frequency_in_minutes>

   For example, if the public directory you want to install the library into is `/var/www/html/js/`, run:

       $ ./adblock.sh --install /var/www/html/js/ 60

   This will download `aclib` file and re-download it into `/var/www/html/js/` every `60` minutes
3. Check if the cron job has been set by listing it using:

       $ ./adblock.sh --list

   If installation is successful, the following output should be printed:

       (1) Path: /var/www/html/js/ Frequency: Every 60 minute(s)

4. Include the library on your page where you want to show ads. 
   Make sure it has one instance per page only.
   For example:

       <script type="text/javascript" src="js/aclib"></script>

5. Anywhere below the library inclusion, run your ads. 
   For example, running pop with zone ID equal to 123456:
   ```
   <script>
     aclib.runPop({zoneId: '123456'});
   </script>
   ```

## Uninstall:
1. In order to uninstall, use the `--uninstall` option. Syntax:

       $ ./adblock.sh --uninstall <path_to_directory>

   If not sure, you can easily find your current installations and their paths by using the `--list` option.

   For example, if your directory is `/var/www/html/js/`, run:

       $ ./adblock.sh --uninstall /var/www/html/js/

2. Remember to remove the library inclusion as well as any javascript code that is utilising it.
