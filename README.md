# Continuation of [the original project](https://github.com/netspooky/inhale)

Inhale is a malware analysis and classification tool that is capable of automating and scaling many static analysis operations.

This is the beta release version, for testing purposes, feedback, and community development.

## Contents
- [Install](#Install)
- [Usage](#Usage)
- [DataModel](#DataModel)
- [Thanks](#Thanks)

----

## Install

This tool is built to run on Linux using Python3, ElasticSearch, radare2, yara and binwalk. jq is also needed to pretty print output from the database. Here are some of the basic instructions to install.

### Requirements

    python3 -m pip install -r requirements.txt

---

### ElasticSearch
[Documentation](https://www.elastic.co/start)

---

### Radare2

It's important to install radare2 from the [repo](https://github.com/radare/radare2), and not your package manager. Package manager versions don't come with all the bells and whistles required for inhale.

    git clone https://github.com/radare/radare2
    cd radare2
    sys/install.sh

---

### Yara

[Documentation](https://yara.readthedocs.io/en/v3.10.0/gettingstarted.html)

If you get any errors about shared objects, try this to fix it.

    sudo sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf'
    sudo ldconfig

---

### binwalk

It's most likely best to simply install binwalk from the [repo](https://github.com/ReFirmLabs/binwalk). 

    git clone https://github.com/ReFirmLabs/binwalk
    cd binwalk
    sudo python3 setup.py install

More information on installing additional features for binwalk is located [here](https://github.com/ReFirmLabs/binwalk/blob/master/INSTALL.md).

---

## Usage 

Specify the file you are scraping by type:

    -f infile    
    -d directory
    -u url
    -r recursive url

Other options:

    -t TAGS        Additional Tags
    -b             Turn off binwalk signatures with this flag
    -y YARARULES   Custom Yara Rules
    -o OUTDIR      Store scraped files in specific output dir (default:./files/<date>/)
    -i             Just print info, don't add files to database

## Examples

Running inhale.py will perform all of the analysis on a given file/directory/url and print it to your terminal.

View info on /bin/ls, but don't add to the database

    python3 inhale.py -f /bin/ls -i 

Add directory 'malwarez' to database

    python3 inhale.py -d malwarez

Download this file and add to the database

    python3 inhale.py -u https://thugcrowd.com/chal/skull

Download everything in this remote directory, tag it all as "phishing":

    python3 inhale.py -r http://someurl.com/opendir/ -t phishing

PROTIP: Use [this](https://twitter.com/search?q=%23opendir&f=live) Twitter hashtag search to find interesting open directories that possibly contain malware. Use at your own risk.

## Yara

You can pass your own yara rules with -y, this is a huge work in progress and almost everything in "YaraRules" is from https://github.com/kevthehermit/PasteHunter/tree/master/YaraRules. Shoutout [@KevTheHermit](https://twitter.com/kevthehermit)

### Querying the Database

Use db.sh to query (Soon to be a nice script)

    db.sh *something* | jq .

---

## DataModel

The following is the current data model used for the elasticsearch database. Not every one of these will be used for every given file. Any r2_* tags are typically reserved for binaries of some sort.

| Name        | Description                 |
| ----------- |-----------------------------|
| filename    | The full path of the binary |
| file_ext    | The file extension |
| filesize    | The file size |
| filetype    | Filetype based on magic value. Not as reliable as binwalk signatures. |
| md5         | The files MD5 hash |
| sha1        | The files SHA1 hash |
| sha256      | The files SHA256 hash |
| added       | The date the file was added |
| r2_arch     | Architecture of the binary file |
| r2_baddr    | The binary's base address |
| r2_binsz    | The size of the program code |
| r2_bits     | Architecture bits - 8/16/32/64 etc. |
| r2_canary   | Whether or not stack canaries are enabled |
| r2_class    | Binary Class |
| r2_compiled | The date that the binary was compiled |
| r2_dbg_file | The debug file of the binary |
| r2_intrp    | The interpreter that the binary calls if dynamically linked |
| r2_lang     | The language of the source code |
| r2_lsyms    | Whether or not there are debug symbols |
| r2_machine  | The machine type, usually means the CPU the binary is for |
| r2_os       | The OS that the machine is supposed to run on |
| r2_pic      | Whether or not there is Position Independent Code |
| r2_relocs   | Whether or not there are relocations |
| r2_rpath    | The run-time search path - if applicable |
| r2_stripped | Whether or not the binary is stripped |
| r2_subsys   | The binary's subsystem |
| r2_format   | The binary format |
| r2_iorw     | Whether ioctl calls are present |
| r2_type     | The binary type, whether or not it's an executable, shared object etc. |
| yara        | Contains a list of yara matches |
| binwalk     | Contains a list of binwalk signatures and their locations in the binary |
| tags        | Any user defined tags passed with the -t flag. |
| url         | The origin url if a file was remotely downloaded |
| urls        | Any URLs that have been pulled from the binary |
---

## ElasticSearch index field limit

If you get an error like this:

    elasticsearch.exceptions.RequestError: RequestError(400, 'illegal_argument_exception', 'Limit of total fields [1000] in index [inhaled] has been exceeded')

You may have an older version of elasticSearch. You can upgrade, or you can increase the fields limit with this one liner.

    curl -XPUT 'localhost:9200/inhaled/_settings' -H 'Content-Type: application/json' -d'{ "index" : { "mapping" : { "total_fields" : { "limit" : "100000" }}}}'

---

## Thanks

I'd like to thank everyone who helped to test this tool with me. I'd also like to thank [Plazmaz](https://twitter.com/Plazmaz) for doing an initial sweep of the code to make it a bit neater.

Greetz to: hermit, plazmaz, nux, x0, dustyfresh, aneilan, sshell, readme, dnz, notdan, rqu, specters, nullcookies, [ThugCrowd](https://twitter.com/thugcrowd), and everyone involved with [ThreatLand](https://twitter.com/threatland) and the TC Safari Zone.
