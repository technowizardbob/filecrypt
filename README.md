## filecrypt

This is an encryption utility designed to backup a set of files. The
files are packed into a gzipped tarball in-memory, and this is encrypted
using NaCl via a scrypt-derived key.

It derives from the `passcrypt` utility in the
[cryptutils](https://github.com/kisom/cryptutils/), and was written as
an example for the book "Practical Cryptography with Go."


## Motivations

This program arose from the need to backup and archive files on
removeable media that may be restored on multiple platforms. There
aren't any well-supported and readily available disk encryption systems
that work in this type of environment, and using GnuPG requires GnuPG,
the archiver, and a suitable decompression program to be provided. This
program is statically built and can run standalone on all the needed
platforms.


## Security model

This program assumes that an attacker does not currently have access
to either the machine the archive is generated on, or on the machine
it is unpacked on. It is intended for medium to long-term storage of
sensitive data at rest on removeable media that may be used to load data
onto a variety of platforms (Windows, OS X, Linux, OpenBSD), where the
threat of losing the storage medium is considerably higher than losing a
secured laptop that the archive is generated on.

Key derivation is done by pairing a password with a randomly-chosen
256-bit salt using the scrypt parameters N=2^20, r=8, p=1. This makes
it astronomically unlikely that the same key will be derived from the
same passphrase. The key is used as a NaCl secretbox key; the nonce for
encryption is randomly generated. It is thought that this will be highly
unlikely to cause nonce reuse issues.

The primary weaknesses might come from an attack on the passphrase or
via cryptanalysis of the ciphertext. The ciphertext is produced using
NaCl appended to a random salt, so it is unlikely this will produce any
meaningful information. One exception might be if this program is used
to encrypt a known set of files, and the attacker compares the length of
the archive to a list of known file sizes.

An attack on the passphrase will most likely come via a successful
dictionary attack. The large salt and high scrypt parameters will
deter attackers without the large resources required to brute force
this. Dictionary attacks will also be expensive for these same reasons.


## Usage

```
Usage:
filecrypt [-h] [-o filename] [-k] [-q] [-t] [-u] [-v] [-x] files...

	-h 		Print this help message.

	-p 		Do not use a password.

	-g 		(Optional) Generate a new key file, specified by given key file.

	-k		(Optional) Use this keyfile, along with password or none.

	-o filename	The filename to output. If an archive is being built,
			this is the filename of the archive. If an archive is
			being unpacked, this is the directory to unpack in.
			If the tarball is being extracted, this is the path
			to write the tarball.

			Defaults:
				   Pack: files.enc
				 Unpack: .
				Extract: files.tgz

	-q		Quiet mode. Only print errors and password prompt.
			This will override the verbose flag.

	-t		List files in the archive. This acts like the list
			flag in tar.

	-u		Unpack the archive listed on the command line. Only
			one archive may be unpacked.

	-v		Verbose mode. This acts like the verbose flag in
			tar.

	-x		Extract a tarball. This will decrypt the archive, but
			not decompress or unpack it.

Examples:
	filecrypt -o ssh.enc -k ~/.my_fsc.key ~/.ssh
		Encrypt the user's OpenSSH directory to ssh.enc.

	filecrypt -o backup/ -k ~/.my_fsc.key -u ssh.enc
		Restore the user's OpenSSH directory to the backup/
		directory.

	filecrypt -u ssh.enc -k ~/.my_fsc.key
		Restore the user's OpenSSH directory to the current directory.

	filecrypt -g ~/.my_fsc.key
		Make a new key file to be used later on...	
```

## INSTALL

$ cd filecrypt
$ build go
$ sudo cp filecrypt /usr/local/bin/
# Generate a Key File for use with filecrypt passwords
$ filecrypt -g ~/.config/filecrypt/tts.key
NOTE: if your key name or path is different then update the mkeys.sh Bash Script...

### How to Require a USB Stick for SSH Access, if desired to do so, :

# Make a copy of your private keys from id_rsa, id_ecdsa, id_ed25519, etc... into yourName.private or serverName.private
$ cp ~/.ssh/id_rsa ~/.ssh/YourName.private

# To Save SSH keys to USB Stick Drive (Plug-IN & Mount the Drive Now):
Note: The USB Stick needs to be formated at this point...
AS a paranoid option (if a new USB drive ONLY): Format (will erase all drives data so make sure that is desired and is correct DRIVE) the NEW USB stick as ext 4 LUKS password protected Volume [using Disks program in Ubuntu]- remember that PWD now forever!
Give the Drive a Good Name (like SafeBox or something else cool that makes since to you).
cd into USB Drive via Open Terminal Here in nautilus or other File Manager or simply cd /media/$USER/USB_Drive_Volume_Name_HERE
$ filecrypt -o ssh.enc -k ~/.config/filecrypt/tts.key ~/.ssh/*.Private
Verify that the file is valid then move on to make a Symbolic link to it:
$ filecrypt -t -v -k ~/.config/filecrypt/tts.key -u ssh.enc
$ sudo ln -s /media/$USER/NAME_OF_USB_Drive_to_Mount/ssh.enc /mnt/ssh.enc

# Robert's Bash Scripts to mount USB keys into RAM Disk for .ssh Keys to work
$ sudo cp shell_scripts/*.sh /usr/local/bin/
# Okay, to make the mkeys work REPLACE Robs.private with your Private KEY file name
$ ln -s /mnt/ramdisk/Robs.private ~/.ssh/
# Update your ~/.ssh/config to use the .Private key file, as follows:
$ nano ~/.ssh/config

```
Host MyServerName_HERE
    HostName MyDomain.com_HERE
    Port 22
    User my_UserName_HERE
    IdentityFile ~/.ssh/Robs(OR_YOUR_NAME_Or_SERVER_Name_Goes_HERE).private
```

# Try it out now:
$ mkeys.sh
$ ssh MyServerName_HERE

Here is how to Mount the USB keys Run (mkeys.sh) - here is it's contents:
```
#!/bin/bash

# NOTE /mnt/ssh.enc is a link to USB drive with said file.

if [ ! -r "/mnt/ssh.enc" ];
then
   echo "Insert usb key"
   exit 1
fi
[ ! -f /dev/ram0 ] && sudo mkfs -t ext2 -q /dev/ram0 4M
[ ! -d /mnt/ramdisk ] && sudo mkdir -p /mnt/ramdisk
sudo mount /dev/ram0 /mnt/ramdisk
sudo filecrypt -o /mnt/ramdisk -k ~/.config/filecrypt/tts.key -u /mnt/ssh.enc
sudo chown -R $USER:$USER /mnt/ramdisk
#sudo chmod -R 600 /mnt/ramdisk
sudo chmod 755 /mnt/ramdisk
```

To Exit / Eject RAMDisk with your Private Keys - run (exitkeys.sh)

Once, your sure everything worked by Testing it out, you may move your ~/.ssh .Private Keys elsewhere, keep all configs and Public keys as is!

## ChangeLog

I (Robert...) made minnor changes/Tweaks to this program, here they are:
1) To allow for a key file.
2) To remove folder path info in TAR arachives (as it did not decode 100% of the time for me and was not how I wanted the folders to output anyways).

My changes made are noted in these files: archive_DIFF.patch.log, and filecrypt_DIFF.patch.log .

Here is the Diff Patch on Archive.Go:
```
--- /home/bobs/code/go/archive_orig.go
+++ /home/bobs/code/go/filecrypt/archive/archive.go
@@ -10,6 +10,7 @@
 	"io"
 	"os"
 	"path/filepath"
+	"strings"
 
 	"github.com/kisom/sbuf"
 )
@@ -41,11 +42,14 @@
 				return errors.New("filecrypt: failed to compress " + path)
 			}
 
+			full_dir, file := filepath.Split(path)
+			working_dir, _ := filepath.Split(walkPath)
+			filePath := strings.ReplaceAll(full_dir, working_dir, "") + file
+
 			if Verbose {
-				fmt.Println("Pack file", path)
+				fmt.Printf("Pack file: %s, as: %s\n", path, filePath)
 			}
 
-			filePath := filepath.Clean(path)
 			hdr, err := tar.FileInfoHeader(info, filePath)
 			if err != nil {
 				return err
```

Here is my Diff Patch on FileCrypt.Go:
```
--- /home/bobs/code/go/filecrypt_orig.go
+++ /home/bobs/code/go/filecrypt/filecrypt.go
@@ -12,9 +12,10 @@
 	"github.com/gokyle/readpass"
 	"github.com/kisom/filecrypt/archive"
 	"github.com/kisom/filecrypt/crypto"
+	"github.com/kisom/filecrypt/genkey"
 )
 
-var version = "1.0.0"
+var version = "1.1.5"
 
 func dieIf(err error) {
 	if err != nil {
@@ -44,8 +45,11 @@
 }
 
 func main() {
+	nopwd := flag.Bool("p", false, "no password")
 	help := flag.Bool("h", false, "print a short usage message")
 	lower := flag.Bool("l", false, "use the lower scrypt settings")
+	generateKey := flag.String("g", "", "key file")
+	keyfile := flag.String("k", "", "key file")
 	out := flag.String("o", "", "output path")
 	flag.BoolVar(&quiet, "q", false, "do not print any additional output")
 	list := flag.Bool("t", false, "list files")
@@ -54,6 +58,11 @@
 	extract := flag.Bool("x", false, "extract .tgz from archive")
 	flag.Parse()
 
+	if *generateKey != "" {
+		genkey.MakeKey(*generateKey)
+		return
+	}
+
 	if *help || flag.NArg() == 0 {
 		usage()
 		return
@@ -81,32 +90,50 @@
 	var pass []byte
 	var err error
 
-	if !(*unpack || *extract || *list) {
-		for {
+	if *nopwd {
+		// no password
+		if *keyfile == "" {
+			dieWith("Must use a password, keyfile, or both!")
+		}
+	} else {
+		if !(*unpack || *extract || *list) {
+			for {
+				pass, err = readpass.PasswordPromptBytes("Archive password: ")
+				dieIf(err)
+
+				var confirm []byte
+				confirm, err = readpass.PasswordPromptBytes("Confirm: ")
+				dieIf(err)
+
+				if !bytes.Equal(pass, confirm) {
+					fmt.Println("Passwords don't match.")
+					continue
+				}
+
+				crypto.Zero(confirm)
+				break
+			}
+		} else {
 			pass, err = readpass.PasswordPromptBytes("Archive password: ")
 			dieIf(err)
-
-			var confirm []byte
-			confirm, err = readpass.PasswordPromptBytes("Confirm: ")
-			dieIf(err)
-
-			if !bytes.Equal(pass, confirm) {
-				fmt.Println("Passwords don't match.")
-				continue
-			}
-
-			crypto.Zero(confirm)
-			break
-		}
+		}
+	}
+	start := time.Now()
+
+	var new_pass []byte
+	if *keyfile != "" {
+		// Open keyfile for reading
+		file, err := os.Open(*keyfile)
+		dieIf(err)
+		data, err := ioutil.ReadAll(file)
+		new_pass = append(data, pass...)
 	} else {
-		pass, err = readpass.PasswordPromptBytes("Archive password: ")
-		dieIf(err)
-	}
-
-	start := time.Now()
+		new_pass = pass
+	}
+
 	if *unpack || *extract || *list {
 		if flag.NArg() != 1 {
-			dieWith("only one file may unpacked at a time.")
+			dieWith("Only one file may unpacked at a time.")
 		}
 
 		print("Reading encrypted archive...")
@@ -114,7 +141,7 @@
 		dieIf(err)
 
 		print("Decrypting archive...")
-		in, err = crypto.Open(pass, in)
+		in, err = crypto.Open(new_pass, in)
 		dieIf(err)
 
 		if *unpack {
@@ -133,7 +160,7 @@
 		dieIf(err)
 
 		print("Encrypting archive...")
-		fData, err = crypto.Seal(pass, fData)
+		fData, err = crypto.Seal(new_pass, fData)
 		dieIf(err)
 
 		print("Writing file...")
@@ -144,15 +171,21 @@
 	printf("Completed in %s.\n", time.Since(start))
 }
 
+// Kyle Isom <kyle@tyrfingr.is>
 func usage() {
 	progName := filepath.Base(os.Args[0])
-	fmt.Printf(`%s version %s, (c) 2015 Kyle Isom <kyle@tyrfingr.is>
-Released under the ISC license.
+	fmt.Printf(`%s version %s, (c) 2022 Robert Strutts
 
 Usage:
-%s [-h] [-o filename] [-q] [-t] [-u] [-v] [-x] files...
+%s [-h] [-o filename] [-k] [-q] [-t] [-u] [-v] [-x] files...
 
 	-h 		Print this help message.
+
+	-p 		Do not use a password.
+
+	-g 		Generate a new key file, specified by given key file.
+
+	-k		Use this keyfile, along with password or none.
 
 	-o filename	The filename to output. If an archive is being built,
 			this is the filename of the archive. If an archive is
@@ -181,15 +214,17 @@
 			not decompress or unpack it.
 
 Examples:
-	%s -o ssh.enc ~/.ssh
+	%s -o ssh.enc -k ~/.my_fsc.key ~/.ssh
 		Encrypt the user's OpenSSH directory to ssh.enc.
 
-	%s -o backup/ -u ssh.enc
+	%s -o backup/ -k ~/.my_fsc.key -u ssh.enc
 		Restore the user's OpenSSH directory to the backup/
 		directory.
 
-	%s -u ssh.enc
+	%s -u ssh.enc -k ~/.my_fsc.key
 		Restore the user's OpenSSH directory to the current directory.
 
-`, progName, version, progName, progName, progName, progName)
-}
+	%s -g ~/.my_fsc.key
+		Make a new key file to be used later on...	
+`, progName, version, progName, progName, progName, progName, progName)
+}

```

## License

filecrypt is released under the ISC license.

```
Copyright (c) 2015 Kyle Isom <kyle@tyrfingr.is>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above 
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. 
```

