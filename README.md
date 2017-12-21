# Xymon Notes Editor
A web-based editor for modifying your server notes files in Xymon.  Xymon's built-in notes viewer will pick up any changes you make.

|     |     |
| ------------- | ------------------------------------ |
| Maintainer    | [Galen Johnson](solitaryr@gmail.com) |
| Compatibility | Xymon 4.2, Xymon 4.3 |
| Requirements  | Perl, HTML::FromText, perl-CGI |
| Download      | None |
| Last Update   | 2012-01-03 |

##### Installation
  * Install the prerequisite perl modules
  * Create the notesdata directory ($XYMONSERVER/etc/notesdata) with ownerships and permissions for your webserver to write to it.  
```bash
mkdir -m 775 /usr/local/xymon/server/etc/notesdata
chgrp apache /usr/local/xymon/server/etc/notesdata
```

  * Update the code for your paths
  * Put the header and footer file under $XYMONSERVER/web
  * Put the xymnote_editor.cgi script under the $XYMON/cgi-secure
  * Update your Administration links in $XYMONSERVER/www/menu/menu_items.js with
  ```
['Edit Notes', '/xymon-seccgi/xymnote_editor.cgi'],
```
  * **UPDATE:** Ubuntu or Debian users should modify this file instead ```/etc/hobbit/web/menu.cfg```
  * Insert the following line in Administration section
```html
 <a class=\"inner\" href=\"$BBSERVERSECURECGIURL/xymnote_editor.cgi\">Edit Notes</a><span class=\"invis\"> | </span> \
```
  * For xymon 4.3.5 insert following line in $XYMONSERVER/etc/xymonmenu.cfg
  ```html
<a class="inner" href="$XYMONSERVERSECURECGIURL/xymnote_editor.cgi">Edit Notes</a><span class="invis"> | </span>
```

##### Known  Bugs and Issues

##### To Do
- [ ] Drop BB support
- [ ] Include an html editor like TinyMCE
- [ ] Use xymon notes folder instead of symlink

##### Credits
  * Chris Naude who wrote the [original BB script](http://www.deadcat.net/viewfile.php?fileid=943)


##### Changelog
  * **2012/01/03**
    * Adjustments made to make it work and display properly in xymon 4.3.x. My thanks goes to KVDO
    * for helping me out with the javascript code and everybody that worked on this add-on.
    * Note: Working but code not perfect.

  * **2010-11-03**
    * Removed the local statement on line 224 in the cgi script as it gave errors when compiling.
    * Changed <my local ($oldbar) = $|;>  into  <my ($oldbar) = $|;>

  * **2010-08-14**
    * Minor modification to explicitly set the package for local variables (ie, add "my")

  * **2009-11-26**
    * Updated the installation section. Ubuntu/Debian uses menu.cfg instead

  * **2007-07-02**
    * Added code to force Perl to flush its buffers after each output statement.  This will, hopefully, address any 'premature end of script headers' errors.

  * **2007-05-05**
    * Updated to use strict
    * Config variables are added to environment
    * Capture hosts in include files

  * **2007-05-01**
    * Initial release
