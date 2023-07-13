# Counter-Strike: Source .nav Generator

There is an issue where if you download a mappack and it only has `.bsp` map files and no `.nav` files - the server on first launch will try and generate the navigation meshes for all maps on the server.

Creating an empty `.nav` file does not work as Source treats it as if the file doesn't exist anymore

What you can do is take any `.nav` file which was generated without navigation meshes (They're usually `205 Bytes` in size) and just duplicate it to match all of the map names in the server which this script does.

I have provided a `.nav` template which is not ignored by Source but does not have any navigation meshes generated and a `bash` script which copies the template for every `.bsp` that is found inside your servers `map` directory.

```sh
git clone https://github.com/Sidicer/css-ng.git
cd css-ng
./css-ng.sh -i /home/cssserver/serverfiles/cstrike/maps -o /home/cssserver/serverfiles/cstrike/maps
```

```
Usage:
  ./css-ng.sh [<arguments>]
  ./css-ng.sh -h | Show this screen
  ./css-ng.sh -v | Show [info] level output (Default [err] only)

  ./css-ng.sh -t | Use this if your .nav template is located elsewhere
                   or want to use another .nav template altogeher
  ./css-ng.sh -i | Provide a single .bsp file or a directory 
  ./css-ng.sh -o | Provide a directory for generated .nav files

Example:
  ./css-ng.sh -t /path/to/template.nav -i /path/to/[maps/map.bsp] -o /path/to/navs
  ./css-ng.sh - when used without any parameters tool looks for .bsp
                files in the same directory where css-ng.sh is located
                and generates .nav files in the same directory

```