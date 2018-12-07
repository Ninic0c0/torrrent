  rTorrent tools
=================

### Table of contents

 * [Add Filebot scripts](#Add-Filebot-scripts)
 * [Check log files ](#Check-log-files)

### Add Filebot scripts

Both scripts can be called in the same rtorrent conf.  

postdl.sh -> Use Filebot and a dirty movies/series custom switch  
postrm.sh -> Seach and delete all broken symlink and call filebot cleaner  

```sh
# rtorrent.rc
method.set_key = event.download.erased,filebot_cleaner,"execute2=/<path_to_the_script>/postrm.sh"  
method.set_key = event.download.finished,filebot,"execute2={/<path_to_the_script>/postdl.sh,$d.get_base_path=,$d.get_name=}"
```

### Check log files

```sh
DEBUG_DIR="/opt/rtorrent/log/"

DEBUG_FILE=""
DEBUG_FILE_MOVIES="$DEBUG_DIR/filebot_movies.log"
DEBUG_FILE_SERIES="$DEBUG_DIR/filebot_series.log"
DEBUG_FILE_DEFAULT="$DEBUG_DIR/filebot_default.log"

EXEC_DEBUG="$DEBUG_DIR/postdl.debug"
```

### Information

Tested with:

rTorrent/LibTorrent vers les versions 0.9.7/0.13.7  
FileBot 4.7.7 (r4678) / OpenJDK Runtime Environment 1.8.0_181 / Linux 4.15.18-9-pve (amd64)

### Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request and enjoy!

### Contributors

Check out all the awesome [contributors](https://github.com/PinkSnake/mp3downloader/graphs/contributors).# torrrent
rtorrent Tools
