LF Aligner version 3.12
by András Farkas
Contact: lfaligner@gmail.com

Download the latest release from the original source: https://sourceforge.net/projects/aligner/


*** CONTENTS ***

- Intro
- Licensing
- Technical info
	- Platforms, input file formats
- Use
	- Sample files for testing/learning
	- Input files, notes on doc, docx, rtf and pdf, basic instructions
	- Setup
	- Reviewing alignment
	- Downloading EU and other documents from the web, language codes
	- Very large files
	- Batch alignment using command line arguments
	- Advanced tips: the built-in sentence splitter (segmenter), using your CAT for segmentation, Hunalign, GUI
- Software used
- Miscellaneous minor technical details
	- Input files and how they are handled, tagged formats, running in perl
- Troubleshooting
- Contact
- Disclaimer


*** INTRO ***

LF Aligner is intended for translators who wish to create translation memories from translations made without a CAT tool or from any other text that is available in two or more languages. I wrote it to make what is probably the best open source automatic sentence aligning algorithm, Hunalign (see http://mokk.bme.hu/resources/hunalign) more convenient to use. LF Aligner also has a couple of features designed for larger-scale corpus building, such as handling huge data sets, built-in data filtering, batch mode, automatic segmentation evaluation and unattended operation.
The aligner also has other features like creating TMX files and downloading EU legislation or any other bilingual HTML webpage for alignment (see details on the web features further down).

The reason why you may want to use this simple tool instead of the flashy and complicated aligners from the big players is Hunalign. It uses a smart algorithm to determine which sentence goes with which, relying on sentence length, a dictionary and, as near as I can tell, black magic, and it does a really good job. The upshot is that you don't have to manually pair up the segments, only review the pairings and do any necessary corrections - or not even that. Most of the time you will get a very usable TM without human input.
The accuracy of Hunalign's automatic pairings depends entirely on the quality of the source material (whether you have removed page headers and footers etc.) and whether it has a good dictionary to work with, but percentages in the high nineties are common. (Reasonably good dictionary data is bundled with LF Aligner for more than 800 combinations of 32 languages. You can check the log to see if this dictionary data was used for your alignment.)
The primary output is TMX, but if you don't use TMX-compatible software, the aligner can generate xls files for you. Tab delimited txt files are always generated as well, suitable for use with Apsic Xbench or processing with other tools.

LF Aligner also gives you complete control over the whole process: in the TMX, you can set the date and time, language codes, creator ID, add notes to each segment etc., and you have extensive customisation options regarding a bunch of other features, too. Just open aligner_setup.txt to see the main setup options.

I kept adding information and this readme ended up being pretty long... if you want to get started quickly without reading the whole thing, you can do so by following the steps described in sample/howto.txt, but you should probably come back to this readme later, especially if you get stuck with something.


*** LICENSING ***

LF Aligner is distributed under the GNU General Public License version 3 or newer.
It is free for personal use (use by freelance translators for their work is considered personal use).
You are free to distribute and modify the code, as long as any significant modifications or derived works are also made available under the GPL terms. If you are a developer working on improving LF Aligner or adapting it for some specific purpose, please drop me a line to lfaligner@gmail.com.


*** TECHNICAL INFO ***

OS compatibility:
LF Aligner is a multi-platform aligner. It is developed on Windows 7 and tested on Win7, XP, Linux (Ubuntu) and occasionally OSX. This readme was written mostly with Windows in mind, but things should work the same on other platforms. For notes on running on linux, see Minor miscellaneous technical details. For the time being, the GUI version is only available for Windows.

What it does:
The aligner takes two or more doc, docx, rtf, odt, txt (in UTF-8!), tmx, pdf or HTML files as input and produces autoaligned tab-delimited UTF-8 txt files, xls spreadsheets and TMX files from them. You can review and correct the autoalignment in the xls before the tmx is generated. On the limitations of input files other than txt and tmx, see the Use chapter.

Note about Windows and accented characters:
In Windows, the handling of character encoding in the console (command line window) is badly broken. It rarely displays accented letters correctly... but this doesn't mean the script won't handle them correctly. With the exception of accented letters you yourself type into the console, everything should work fine. So, if you want a TMX user ID or note with accents in it, put it in aligner_setup.txt instead of typing it in when you run the aligner. It may be displayed wrong, but it should be OK in the TMX itself.
This does mean that you may not be able to use the aligner on files with non-ASCII characters in the paths or filenames (especially on Windows). Ideally, you shouldn't be using non-ASCII file and folder names anyway for various boring reasons, so just rename/move the files as needed. File and folder names should contain a-Z latin letters, spaces, underscores, full stops and hyphens, nothing else.

Note about Vista:
To open files, you may need to drag and drop them into the console window. Quite perplexingly, Vista offers no drag and drop to the console, so you'll need to get ingenious (in recent versions, you'll be using a GUI file picker instead of drag and drop by default, so this is less of an issue). You can either switch to a better OS, or enter file paths in some alternative way. You can copy-paste them; select a file and click Commands/Copy full names to clipboard in Total Commander or use right click/Properties in the Vista file explorer. Then paste with the local menu accessed by right clicking the icon in the top left corner of the aligner's window. Alternatively, put the files in a folder inside the "aligner" folder and use [scr]/foldername/filename.

Under the hood:
LF Aligner is a perl script designed to run on various platforms. As Windows does not come with a perl interpreter, the Windows version is packaged into a standalone executable. The mac and linux versions are based on the "naked" perl script (started by a bash script to allow launching by double click). Details of how to mess with the source code are under "miscellaneous minor technical details"


*** USE ***

The folder named "sample" contains a pair of sample files and a txt with instructions on how to use the script. You can follow the instructions there to see the aligner in operation and learn the basics, and then come back to this readme for more detailed information.

The input files can be txt, doc, docx, odt, rtf, tmx, HTML, pdf and a few other formats. Always use UTF-8 encoding in your txt files. See details on preparing input files further below.

No installation is needed, just double click on LF_aligner_XXX to launch the program. A graphical or command line window will open, and prompt you for input as needed. (Note: the initial startup may be very slow on Windows. Just wait until the first prompt appears; it will show up eventually, and things will speed up from then on.) Read the prompts, type or click what you are asked to and press Enter or click Next. Any error messages will also be displayed in the same window. If something went wrong, read the error messages carefully, check the log in the scripts folder, then run the program again if you have an idea about what went wrong.
To "uninstall", just delete the aligner folder. LF Aligner makes no changes to the registry or other system settings, so the aligner folder is all there is.

It is highly advisable to create a new folder for each new alignment project, containing only the two files to be aligned, or else old files may be overwritten etc. Your project folder can be anywhere on your computer. (Note: on Windows, use only ASCII characters in file and folder names!) If you use the web features (to download and align EU legislation etc.), your files will be downloaded to the program folder.


Note on all input document formats:
The import of every "rich text" document format, i.e. everything apart from txt and (hopefully) tmx is potentially lossy.
E.g. if your pdf, html, doc, docx, rtf or other file contains tables, they are probably going to come out wrong. Tables are best handled manually, i.e. you should move each cell to a separate line for best results. Most other elements that occur in running text are handled well, but no promises, especially with pdf. Hyperlinks, special symbols, footnotes, sidenotes, page headers and generally everything other than running text with "normal characters" may not come out the way you expect them to. Txt input files are always going to be the safest, so use txt whenever you can.
See "Using your CAT to extract/segment text:" on how to get around the problem by piggybacking on your CAT tool.


Note on doc import: this is done with Antiword, which seems to work really well, although I haven't bothered testing it very much. Headers and footers are not conserved, but hidden text is. Footnotes are added to the end of the document. Pictures are represented by [pic], which the aligner subsequently deletes if it's on a line by itself.
On Windows, doc conversion should work out of the box, just launch LF Aligner and drop in your doc files. The Windows version of Antiword requires the file C:\antiword\UTF-8.txt, so this is created by the aligner. This is the only file the aligner creates or modifies outside of its own folder. (Note: disregard the "I can't find the name of your HOME directory" messages, they are of no importance.)
On non-Windows systems, you'll have to install Antiword yourself. Sudo apt-get install antiword should take care of it in Debian, Ubuntu & co - in other distros, check your package manager. If you are an OS X user, these should get you started: http://www.winfield.demon.nl/ http://antiword.darwinports.com/ 
As always, check the results; comparing the word/character numbers reported by the aligner to the word count numbers from Word is probably a good idea. Of course, txt will always be the most reliable input format, so if you want to be absolutely, 100% certain that the alignment contains the text you want it to, convert your text to txt yourself and make sure it's kosher before running the aligner.

Note on docx import: this uses docx2txt, which is bundled with LF Aligner in all versions, and it should usually work well, extracting text even from corrupted docx files. Page headers, footers and footnotes are removed - I consider that a feature, not a bug. Hidden characters are conserved, so delete them first if you don't want them in your TM.
The same caveats apply as with .doc. 

Note on rtf import: this is done with Abiword. If you're on OS X or Linux, you'll need to install Abiword yourself. In Ubuntu, you'll find it in the software centre. Also, see http://www.abisource.com/download/index.phtml
Abiword is also the aligner's last line of defence against odd input files: if you specify the generic "t" filetype and the extension is not txt, doc or docx, Abiword is used to try and convert your file to txt. It should work with Abiword's own abw files, as well as docm, odt and a couple of other file formats. You can probably install some Abiword plugins and get support for even more weird and wonderful file formats.

Notes on pdf import:
Obviously, this won't work with pdf files that contain images of scanned documents - unless they happen to be special two-layer OCRed pdf files that contain the underlying text as well as the image.
Remember: don't expect perfection. The pdf format is horrible; extracting text reliably is simply not possible with any automated method. That's just the way pdf is, there is nothing you can do about it except thank Adobe and the document's author.
There are 4 options you can try with pdf, with each producing slightly different end results. There is no best way, what's best for a given file depends on the file itself.

1) Use "Save as text" in Acrobat Reader, then resave the txt in UTF-8 and run the aligner on the txt file in pdf (p) mode
2) Run the aligner directly on the pdf files with default settings
3) Run the aligner directly on the pdf files after changing the "Pdf conversion mode" option in the setup file to n
4) Copy-paste text out of the pdf into a txt and run the aligner on that in txt (t) mode

Generally, 1), i.e. exporting to txt format in Acrobat Reader works a bit better than feeding the pdf to the aligner directly if the file has non-linear text placement, such as text in columns or tables or the margins of the page. For this reason, exporting is always recommended for pdf files. The procedure is as follows: open the pdf in Adobe Acrobat Reader, click File/Save as text. Then open the resulting txt file with Notepad, choose File/Save as and resave with UTF-8 encoding. Then just use the "p" file type in the aligner. Do NOT run the aligner in "t" mode on exported pdf files!
The built-in converter (used in options 2 and 3 above) is mainly designed to be used if you have many files to align and exporting them one by one would be too time-consuming (i.e. it's mostly designed to be used in batch mode). You can configure its behaviour with the "Pdf conversion mode" setting in setup (the "y" setting works better with tables, it makes the txt files easier to review and does a better job of keeping separate segments separated, so "y" is the default even though it does a worse job with side notes and columns).
Overall, it is a bit worse with non-linear text than exporting from Acrobat Reader. It's absolutely fine for simple running text, though... Except that page headers and footers are left in the text because it's not really possible to automatically filter them out. That's another "feature" you can thank Adobe for.
You could also try copy-pasting from the pdf into a txt file, but once you have a pdf open in Acrobat Reader, you're better off just exporting.

If your originals are in some unsupported format, either save them in .doc or .docx or copy-paste their content into Notepad (or any other text editor) and save them as TXT with UTF-8 encoding (this is not Notepad's default so you explicitly have to set UTF-8 in the "Save as" dialog). See "Using Trados to extract/segment text" for tips on possible ways to handle .ppt and generally any format your CAT is compatible with.

Remove page numbers and page headers/footers from your txt files before running the aligner (this is usually only needed if the original was a pdf). Read up on Microsoft Word's wildcard search and replace to figure out how to remove headers/footers containing a running page number with one command: accurapid.com/journal/15msw.htm
This is important, as, if you leave them in, Hunalign will diligently pair up the nicely matching page headers/footers with each other and consequently mess up the alignment of the text in between - unless page breaks are applied in a uniform manner in the originals.


Setup:

You've probably noticed the file aligner_setup.txt. This file allows you to extensively customize LF Aligner's behaviour. Just open it and change the values in [] as you see fit.

If your txt (xml, etc.) file contains tags enclosed in <> and you want to get rid of them, change the extension to html and tell the script it's an html file. Everything enclosed in <> will be deleted except for <p>, <P>, <br> and <br /> which will be converted to line breaks (and thus become segment delimiters). To enforce segment breaks, insert <p> tags (line breaks are ignored in tagged files).

The script creates backup copies of the original txt files in the folder source_files_backup.
Other output files: aligned_XXX.txt is the tab delimited aligned file Hunalign produces, i.e. the main output file. (The 3rd column contains the source info, and the 4th column contains the match confidence value.) The .xls has the same content, with reviewing instructions. XXX.tmx... well, no points for guessing that one.


Tips for reviewing alignment:

Instructions on how to do this in Excel are on worksheet 2 of the xls file generated by the aligner. A macro is provided in aligner/scripts/MergeCells.xla to speed up the process.

Alternative solution with PlusTools:
PlusTools, the free word macro from Yves Champollion offers an "aligner" that allows you to manually align files and create Wordfast TMs from them. You may find its user interface convenient for revising/correcting the autoalignment of your texts and use it instead of Excel. If you work with Wordfast, you may also want to use PlusTools to create Wordfast TMs from files aligned with the aligner instead of generating a TMX and then importing that into Wordfast.
All you need to do is fool PlusTools into thinking that it's working on an alignment (a Word table) it created itself. To do so, you need to:
- Install PlusTools ( http://www.wordfast.net/index.php?whichpage=plustools&lang=engb )
- Close any open MS Word windows. Open aligner/scripts/Plustools_dummyfile.doc, which contains a two-segment alignment done with Plustools, and click PlusTools/Align/Start Alignment to bring up the alignment correction buttons in the Plustools toolbar. Leave this MS Word window open. (Note: make absolutely sure you don't move/delete/rename/modify any other files or folders is aligner/scripts!)
- Open the aligned_XXX.txt created by the aligner, select all text and copy to clipboard. Open a new, empty MS Word window and paste the text. Click Table/Convert/Convert text to table.
- Now you should have a table with your autoaligned text and the PlusTools aligner buttons (Ins, Del, Merge and Split) in the Word toolbar. You can now close Plustools_dummyfile.doc and work on your file. Use the buttons to correct the alignment, obviously, making sure not to push the two columns out of sync. When you are done, copy-paste back to the .txt and save, or use PlusTools/Align/Create TM to create a Wordfast TM.
This is just a basic description of the process; if you need more info on how PlusTools works, consult the PlusTools manual.

Note: I'm sure you could even try and use Winalign or some other random aligner if you have some strange perversion that compels you to do such things. You'd have to separate the two columns into two files and feed these two files into Winalign, making sure to set it up so it respects the line breaks as segment delimiters and doesn't split segments any further. Then you could use Winalign's UI to do the review and create a TM, having let Hunalign do most of the hard work. Honestly, I think it's not worth bothering with. The Winalign UI or any other aligner UI is unlikely to work significantly better than Excel or PlusTools.


Web features:

To download EU legislation, you only need to provide the CELEX number (or the Comission proposal's year and number, or the EP report's year and number) and pick your languages (use the two-letter language codes provided below when prompted by the program). Of course the document may not be available in both languages.
These files are segmented in a very uniform and orderly fashion, so if you pick paragraph level segmenting (i.e. do not run the segmenter), you are very likely to get a perfect automatic alignment. Even if you run the segmenter, you can safely expect well over 95% correct autoalignment. (Note: the fine folks at the Commission's Joint Research Centre have already created a rather large TM out most of the pre-2007 legislation, so you may want to check that out at http://langtech.jrc.it/DGT-TM.html before setting out to use this script to download large numbers of documents, which would just be a massive waste of your time as they are already in the DGT-TM anyway. (It could also get you IP-banned from the websites where the EU posts these documents, in which case you couldn't access EU legislation even in your webbrowser.) There is yet more material at http://www.statmt.org/europarl/. This feature of the aligner is intended for downloading single (especially post-2007) documents you happen to need, so please only use it for that.)
The script downloads the HTML pages of the documents from eur-lex.europa.eu and the EP's website. See sample URLs under misc. technical details.
If the document you need is not at the appropriate URL, you may be able to find it on one of the many other online EU document repositories, such in the Official Journal that is also published on eur-lex.europa.eu - although as of version 2.1, this will be needed much less often. I you have found your document in HTML somewhere, just run the script in webpage mode and provide the URL. Use HTML sources whenever possible, they are a lot better than the dreadful pdf files. If you landed on a pdf page, just replacing :PDF with :HTML at the end of the URL will often take you to the HTML version of the same document.

Use the two-letter language codes listed at http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
The EU's official languages are as follows: en, fr, de, es, it, hu, bg, cs, da, et, el, lv, lt, mt, nl, pl, pt, ro, sk, sl, fi, sv, ga.

For other webpages, just provide the two URLs when prompted by the script. Manually downloading and converting the pages or copy-pasting their content into a txt file will often work better, but I still included this feature for the lazy ones among us.


Very large files:

LF Aligner was designed from the get-go with very large files in mind; there is no hard limit on how big you can go. Up to about 20,000 segments (sentences) in size, the default settings should work fine. The console window may appear to be doing nothing for half a minute or more if your file is on the plump side, but just wait, it's working in the background, and whenever your intervention is needed, the script will prompt you.
If your file is even larger, activate "chopping mode" by entering a value for the "Chop up files" settings in LF_aligner_setup.txt. A value somewhere between 10000 and 20000 is recommended depending on how much memory you have in your computer.
In this mode, Hunalign chops up the input files to chunks of the specified size, aligns them one by one, and then the aligner merges the output files into one file again.
In this mode, the script writes temporary files to the Aligner folder; just leave them alone, they will be deleted when the script terminates. If the script fails to terminate normally and these files are left there when the command line window is not open anymore, you can safely delete them.

Because the script needs to write and delete the temporary files, you shouldn't place any files in the aligner folder or they may be overwritten or deleted. Files with the extension .align, and files with any extension that matches a two-letter language code you specified when running the script will be deleted. Any file named translate.txt will also be deleted. Again, don't put anything in the aligner folder and you'll be fine. Translate.txt also gets deleted from your project folder, by the way.


Batch alignment using command line arguments:

The old batch aligner was limited to two languages and was a pain to update (which is why it rarely got updated and usually missed some of the newer features of the main programme). Now batch alignments can be done with the "normal" aligner, using command line arguments to specify the file names, filetype and other settings. The old batch aligner is therefore now obsolete. Command line arguments also allow you to integrate LF Aligner with your own software (write software that calls LF Aligner in an automated fashion without human interaction).
The easiest way to use command line arguments in Windows is to open a text editor and type in the commands, one command per line. Save the file as a .bat in the same folder as the aligner, then just double click it to launch. On linux and mac, you need to write a simple bash script that does the same. When launching the aligner with command line arguments, the GUI is switched off.
The arguments (settings) have to be provided with the following syntax: --[argname]="[argvalue]" or --[argname]="[value1]","[value2]". Note that there is no space after the comma. You can enter the arguments in any order, and you can leave out arguments.

The arguments are the following:
Filetype - this should be pretty obvious: t, p or h. Web alignments are not supported to prevent abuse (mass downloads).
Infiles - the (two or more) input files. You have to provide the full file paths, separated by commas.
Languages - the two-letter language codes, separated by commas. Obviously, the order has to be the same as in infiles.
Segment - segmentation settings: y, n or auto.
Review - n (no review), t (open the text file for review), x (open xls for review) or xn (generate an xls file but don't open it for review)
Tmx - y (generate TMX file) or n (don't)
Codes - TMX language codes, separated by commas
Outfile - the full path of an output file, to which the aligned material is appended (useful when running more than one alignment). If you are using command line arguments for batch tasks and your files are not in the same folder, you should always specify an outfile, otherwise the output files will be scattered in various folders (wherever the first file of each of the file pairs is located).

Here's a sample command:
LF_aligner_3.1.exe --filetype="t" --infiles="c:\alignment\input_en.txt","c:\alignment\input_fr.txt" --languages="en","fr" --segment="y" --review="n" --tmx="n"

You have probably noticed that the settings overlap with the settings you can make in LF_aligner_setup.txt. This is intentional, and the settings passed on the command line take precedence, i.e. you can use them to override the settings made in the setup file.
You can also use command line arguments to create several different sets of customized defaults. E.g. you can create an aligner_notmx.bat that launches the aligner and tells it not to ask you about creating a tmx file but create an xls (LF_aligner_3.1.exe --review= "xn" --tmx="n") and an aligner_tmx.bat that always creates a tmx file without asking, but it doesn't create an xls etc.

The argument syntax is somewhat flexible, and the argument names can be abbreviated to the first letter. These styles are all accepted:
-l en,hu,es
-l="en","hu","es"
--Languages="en","hu","es"
-L en,"hu","es"

But these are not:
-l = "en","hu","es" (no spaces allowed around equal sign)
--l="en","hu","es" (no double hyphen if name is abbreviated)
-l="en", "hu", "es" (no spaces after comma)
-l='en','hu','es' (single quotes not allowed)

Thus, the above example command can be more concisely written as:
LF_aligner_3.1.exe -f t -i="c:\alignment\input_en.txt","c:\alignment\input_fr.txt" -l en,fr -s y -r n -t n

Note that file names that contain a space must be in double quotes. Therefore, it's good policy to write all file names in double quotes. As values are comma separated, file names that contain a comma are not supported
There isn't a lot of error checking done on command line input, so make sure you follow the syntax, don't make typos etc. If you get an "Unknown option: xxx" error message when the script starts, you've messed up.
As a general rule, perl - and thus LF Aligner - does not support non-ASCII file names on Windows. However, it appears that command line argument mode is not subject to this limitation. I.e. if you use command line arguments to specify the file names, you can process files like c:\úőóüí\file.txt or c:\folder\ííí.html, which would otherwise be rejected.


Advanced tips:

Character replacements:
If your files suffer some sort of character corruption, or character entities like &#8234; or &auml; don't get translated into the appropriate characters by the aligner for some reason, you can tell the aligner how to handle each occurrence of these characters. There are two conversion tables at the end of the setup file, fill them in appropriately, e.g.

Character conversion table for language 1:
&ouml;	ö
&Ouml;	Ö

Character conversion table for language 2:
&ouml;	ö
&Ouml;	Ö

Remember to remove the character pairs if you don't need them anymore - they will be applied in every project as long as they are in the setup file!
Protip: you can also use this feature to replace words or phrases, and you can even use perl regex - your foo	bar is executed as s/foo/bar/g;. Don't use tab characters, though. I have no idea what will happen if you do, but it probably won't be good.


Sentence splitter (segmenter):
Read the segmenter's own readme (aligner\scripts\sentence_splitter\README.doc) to see how to customize its behaviour by listing the words that do not signify the end of a sentence when followed by a full stop and a capitalized word (such as Mr. or St.) The aligner uses bundled prefix lists for some European languages and defaults to the English list if any other language is specified (the Hungarian list is my own creation, and it's probably not nearly as good as the others).
To add your prefix-lists for new languages, just create a list file for it and place it in scripts\sentence_splitter\nonbreaking_prefixes\. Give the list file the standard two-letter identifier of the language as an extension. It will be used automatically for all texts that you mark with the same language identifier when the aligner prompts you. It's probably not a bad idea to base your lists on the English file. Also, if you use Trados Studio, you can take hints from Studio's list. Go to the Translation Memories view and go to create a new language resource template and open the abbreviation list for editing to view the list Studio uses, and copy what you like. If you send me your nonbreaking prefix list for a new language (or an improved list for a language already supported by LF Aligner), I'll bundle it with LF Aligner from the next release.
Note: you can of course also use your own sentence segmenter/splitter instead of the one provided in the script, as long as it inserts line breaks between segments as delimiters. Just run it on the input files before starting the aligner and then tell the aligner not to segment your text.
As of 2.57, the LF Aligner can evaluate the results of segmentation programmatically, i.e. instead of asking you, it can decide for itself whether to use sentence-segmented file versions or revert to the unsegmented (i.e. paragraph-segmented) originals. To activate this mode, set the "Ask for confirmation" value to auto in the setup file. This feature was designed for those who build corpora out of hundreds or thousands of documents in batch mode and want the best possible unreviewed autoalignment to be produced in an unsupervised process, i.e. without having to evaluate the segmentation of each file pair themselves. The feature is also available in the normal, non-batch aligner as well, though.


Using your CAT to extract/segment text:
You can also use Trados or other CAT tools to segment your source texts, which has the advantage of ensuring that the segmentation in your aligned TM will be the same as the segmentation your CAT produces as you translate - this way you will have a somewhat better chance of getting 100% matches from the TM as you translate. It also allows you to align any file format your CAT can handle (including ppt etc.), not just the ones that are directly supported by LF Aligner.

Presegmented files via TMX
LF Aligner supports TMX as an input format. Process your input files with your CAT of choice, producing TMX files of each, with the same text as both "source" and "target". This is of course tedious to do, but it allows you to process a much wider range of input formats than LF Aligner could ever support, including ppt etc. Your texts are also converted and segmented by your own CAT, which ensures better compatibility (more 100% TM lookup hits) and, usually, better handling of hyperlinks, tables, footnotes, headers etc.

With Trados 2007 or earlier, it should go like this: if the input file is not a .doc, open it with tageditor to create a .ttx file. Save the ttx and close tageditor. Open workbench, create a new TM, click Tools/Translate, pick the .doc or .ttx, check Segment unknown sentences, click Translate. Then click Tools/cleanup, add the (now bilingual) .doc or .ttx, make sure "Update TM" is checked, click Clean up. This imports all segments to the TM, which you can then export to TMX. Repeat with the other input file, then run the aligner on the TMX files (with the "t" filetype).

In Studio, the procedure looks about like this:
Create a project with an empty TM and your input file in one of the languages. Open the file for translation, copy all source segments to target (select first segment, keep shift pressed, scroll down to last segment, click on its number, release shift, right click on segment number, pick copy source to target, right click again, change the satus of all segments to Translated). Click Project/Batch tasks/Update Main Translation Memories. Switch to the TM editor, make sure the "translations" are indeed in the TM, export the TM to TMX. Then repeat the whole procedure with the other language.
This can be done on various file pairs at a time, and you get Trados-extracted and Trados-segmented text.

Using Wordfast to extract/segment text:
Worfast Classic can do sentence segmenting/extraction, too. You should be able to do this with a trial copy.
Open the file in MS Word. In the WFC Control Panel (the little "F"), go to Tools, then go to Tools, and click Extract. Then follow the prompts. The file named WfExtracted.txt is the one you'll need. You can also extract from multiple files, but you can't really control the order in which the files are processed. Also, you can configure the segmentation settings in WFC itself (otherwise it defaults to the settings for English). Note: double check the encoding of WFExtracted.txt and resave in UTF-8 if needed.


Hunalign tips:
Hunalign works even better if it is given a bilingual dictionary. A mix of large glossaries in the areas you work in is probably best, but throw in a large general dictionary as well for good measure. Don't hold back, it can easily handle dictionaries with hundreds of thousands of entries. LF Aligner comes with premade dictionaries for more than 800 language combinations covering all EU languages and many more. If the "Dictionary used by Hunalign" is reported to be anything other than null.dic, then your language combination is covered by the built-in dictionary data.
To add your own dictionary, read Hunalign's documentation. Note that the language that comes first in the dictionary must be specified as the second in the script. This is just an oddity of Hunalign that you have to keep in mind. Place the new .dic in \scripts\hunalign\data\. The new dictionary will now be used by the aligner when appropriate.

GUI:
As of version 2.5, some GUI elements are present in the aligner (a GUI file browser as of 2.52, and a full GUI as of 3.0). By default, the Windows version uses the GUI while other versions don't. You can override this default behaviour in the setup file.
To use the GUI in linux or OS X, you'll need to install the Tk perl module. Linux users can start the CPAN shell with perl -MCPAN -e shell; and install from there. On Ubuntu, the sudo aptitude install perl-tk command should also work, after enabling the universe repository. You can also try your GUI package manager. OS X users are on their own, sorry.


*** SOFTWARE USED ***

Here is a list of the excellent software tools built into LF Aligner that were generously given away for free by their creators:

Of course, the impressive Hunalign provides the core and the main asset of this program.
Read up on its more advanced features, such as automatically discarding segment pairs with low confidence values at:
http://mokk.bme.hu/resources/hunalign

The built-in sentence segmenter comes from:
http://www.statmt.org/europarl/

The pdf->txt converter (pdftotext) was taken from xpdf:
http://www.foolabs.com/xpdf/

The doc->txt converter is Antiword:
http://www.winfield.demon.nl/

The docx->txt converter is from:
http://docx2txt.sourceforge.net/

Rtf, odt and other formats are converted to txt using AbiWord:
http://www.abisource.com/

The Windows unzip utility for docx files is by info-zip:
http://www.info-zip.org/UnZip.html

On Windows, downloads are handled by an old favourite of mine, Wget:
http://www.gnu.org/software/wget/


*** Miscellaneous minor technical details ***

Input: UTF-8 txt or rich text formats, such as doc, docx, pdf or HTML. Unix, Windows and Mac newline characters are all supported on all platforms (in theory, anyway). Character references in HTML (&eacute; &amp; etc.) are converted to their respective characters.
Output: UTF-8 txt, newline characters depending on system (DOS newlines i.e. CRLF on Windows and Unix newlines i.e. LF on Linux and newer Mac systems).

The aligner assumes that all your files have extensions, so don't use any input files named in the extensionless Unix tradition. Sticking to txt, html etc. is advisable as the aligner was not tested with offbeat extensions.

This aligner focuses on presenting correctly aligned meaningful text in the output as opposed to keeping the input files as intact as possible, therefore:
Whitespace is normalized: non-breaking spaces and tabs are converted to normal spaces, multiple spaces are converted to single spaces and segment-starting and segment-ending spaces are removed.
Page break (form feed) characters are converted to line breaks (segment boundaries).
Numbers and chapter/point headings such as (a) or 1b, when standing on their own, are merged with the next segment (this can be disabled in the setup).

If a segment starts with an = sign and you tell the aligner to generate an xls, a space is added before the = to stop Excel trying to interpret the text as a formula. 

To get a "clean" xls wit just the aligned text and no instructions, type "xn". The xls won't be opened for review.

The aligner prints the input file names in the third column of the tab delimited file. Leave the "your note" field empty if you want it to be added to your TMX file.

HTML/XML character references are decoded and tags are stripped if you pick the HTML or web/celex filetype. This can be used for aligning XML files while stripping all the tags.

URLs
The aligner pulls documents from the following URLs:

CELEX (some documents are not on the site by CELEX number; get them via their URL if you manage to find them):
http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CELEX:$celex:$language:HTML
e.g.:
http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CELEX:32007R0967:EN:HTML

COMMISSION PROPOSALS
http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=COM:${comyear}:$number:FIN:$language:HTML
e.g.:
http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=COM:2009:0032:FIN:EN:HTML

EP REPORTS:
http://www.europarl.europa.eu/sides/getDoc.do?pubRef=-//EP//TEXT+REPORT+${eprepyear}-${eprepno}+0+DOC+XML+V0//$l1
e.g.:
http://www.europarl.europa.eu/sides/getDoc.do?pubRef=-//EP//TEXT+REPORT+A7-2010-0023+0+DOC+XML+V0//EN

By default, creation times are recorded in TMX files as GMT time. Your CAT should in principle convert that to your correct local time on importing but I wouldn't bet on that happening - CAT tools can be pretty dumb. To enter a different time, use the format "yyyymmddThhmmssZ" as prompted by the script. As an example, 6 July, 2010, 17:50 would be 20100706T175000Z. The Z stands for GMT time. In principle, you should replace it with the offset of your time zone (say, +0200 etc.) but the chances of your CAT understanding this correct time format are pretty slim. For instance, Trados 7 only seems to understand GMT time (-Z suffix), which it converts to local time, but it does so incorrectly as it has no clue about DST. Then on exporting, it doesn't even convert the time back to GMT, but it slaps on the GMT code (-Z) anyway. So if you take a TM in Trados 7, export it to TMX and import it again, the time will shift depending on what time zone you're in. If you import and export again, it shifts further... Yes, this is as broken as it sounds. Test your own CAT if exact time stamps matter to you for some reason. If you only care about the date, like most translators, just check if the date detected by the aligner is correct, and correct it if needed. If you're happy with the date/time autodetection, just set "Prompt user for creation date and time" to n in the setup file and the script won't harass you with questions about time any more.


The aligner is a perl script that relies on the Spreadsheet::WriteExcel module to generate xls files. The main script is the same for all platforms, with if branching to account for OS-specific features. For Windows, it was packaged into a standalone executable (using PAR::Packer) along with Spreadsheet::WriteExcel and the perl interpreter itself. The OS X and linux version has Spreadsheet::WriteExcel integrated into the main script (with App::Fatpacker) to keep it as a standalone script. As App::Fatpacker can’t inline HTML::Parser, the linux and mac versions have a different HTML stripper/converter than the windows version. Search for “html_convert” in the code and you’ll see.

LF Aligner uses Hunalign, a powerful autoaligner written in portable C++ (http://mokk.bme.hu/resources/hunalign), and a Perl sentence segmenter from the Europarl corpus project (http://www.statmt.org/europarl/). I used PAR::Packer to make a Windows executable from the segmenter; Mac and Linux OSes usually come with Perl preinstalled, so on these platforms, the original Perl script is used.
Note: obviously, the .pl can be tweaked and modded - unlike the executable - and it also has the added benefit of being faster. In particular, the startup of the executable binaries is really slow, whereas you get near-instant startup with the .pl. To get better speed on Windows, just install a perl interpreter and use the all-included XXX_with_modules.pl instead of the premade executable. On other OSes perl is presumed to be preinstalled so the aligner uses the perl scripts to begin with.
"Chopping mode" in Hunalign, i.e. aligning large files in bits and stitching together the output is done with a python script. I created a windows .exe out of the script, other OSes are presumed to have python. This is only needed if the "Chop up files" feature is activated in setup.

Linux
The aligner was tested on Ubuntu 10.10 (Maverick Meercat).
If your linux distro is not binary-compatible with Meercat, you'll need to recompile Hunalign from source. Unpack the source code, navigate to the src folder in terminal and issue the make command. The new hunalign executable should be generated in the hunalign folder. (Note: two alternative linux binaries are provided for earlier Ubuntu versions; you can also try these before you compile your own. Just rename scripts/hunalign/hunalign_linux_1 to hunalign_linux and run the aligner.
Pdftotext also may need to be recompiled for your platform, but of course you won't need it if you don't want pdf support. The newest versions of the aligner check for a previously installed copy of pdftotext in the /usr/bin folder, so the easiest way to get pdf input support is to install pdftotext. Sudo apt-get install poppler-utils should do the trick if your distro has apt-get.
The same applies to .doc support with antiword, except I don't even supply premade binaries. Sudo apt-get install antiword is recommended if you want to align doc files without converting them yourself, or install antiword in whatever way your distro allows.
Almost everything else in LF Aligner is in perl, so the main features should run on pretty much anything you can compile hunalign on.
If you're having "Permission denied" errors regarding pdftotext and hunalign, navigate to aligner/scripts/hunalign, right click on hunalign_linux and change its permissions to executable. Do the same with aligner/scripts/pdftotext/pdftotext_linux.


***TROUBLESHOOTING***

The most frequently occurring source of error is the use of unsupported characters in file and folder names on Windows. Due to a limitation of win32 perl, only input files with ASCII filenames are supported on windows. So, C:\stuff\input file_EN-version1.12.doc is an accepted filename, but C:\stuff\würstel.doc is not, and nor is c:\Users\Adrià\Documents\inputfile.doc. Characters you can use: a-z A-Z 0-9 ,.-_. Some of the characters you can't use: öüóőúéáíâçłś. Cyrillic and oriental characters are out as well, of course.

Most error messages are shown in the console window and are fairly self-explanatory. Read them (and the log in aligner/scripts/log.txt) and try to fix whatever's wrong. If the window disappears before you have a chance to read the error message, open a persistent console window. In Win7, open the Start menu, type cmd in the search field and press Enter. A console window will open. Drag and drop the .exe file in it and press enter to launch the app.

If you're getting a bunch of corrupted characters in your texts, you probably just forgot to save your input txt files in UTF-8 encoding. Do so in a text editor with File/Save as... As of version 2.59, UTF-8 is the only encoding accepted for HTML files, too, so resave your HTML files in UTF-8 (the encoding declaration in the HTML header is ignored by LF Aligner).
If some characters are still wrong in the output files, try using the character replacement functionality described in this readme.
If your originals were pdf files, character corruption is probably caused by subpar pdf authoring, i.e. the source files are crap. In some cases, you can fix it using the character replacer, in others, you can't because the erroneous character matches a character that also occurs in the file. There is nothing you can do with these pdf files short of OCR.


TMX:

If the note or creator name is corrupted in your TMX file, put it in aligner_setup.txt instead of typing it in.

Don't be surprised if the import of a TMX file fails partially of fully. It's a somewhat complicated standard that has gone through various iterations and trying to sort out all possible bugs I could think of just wasn't worth my time. And then there is the sorry state of the use of the standard... the various CATs themselves create (and demand for importing) mutually incompatible TMX files (certainly as regards language codes) so this is a can of worms I'm reluctant to open.
If you get a meaningful error message during a failed import, try to correct the problem. Otherwise, export a memory into TMX with the software you're using and check for differences between that and the TMX generated by LF Aligner. If you have precisely identified what you believe to be a fixable problem with the TMX generation, notify me, describing the issue and the proposed solution (attach short sample files) and I'll try to correct the issue.
If you get a report from your CAT that some entries were not imported, that's not necessarily a problem. It's probably because the TMX contains TUs with one language left empty. It happens quite a lot if you don't fully review autoaligned files. Such entries don't get imported in Trados 7, for example, and that's perfectly fine by me.
TMX import in Trados Studio is picky/broken. If you're having importing problems, import to Trados 2007 first, then export from 2007 to a TMX file and import that into Studio (or "upgrade" the tmw).
HTML-style character entity references are not allowed in TMX (things like &eacute; and &#304;). The aligner converts character references to the characters they stand for, but some could theoretically slip through the net. If you bump into this problem, just find the offending character and remove/replace it before importing. You can add the character to the character conversion tables to solve the problem for all your subsequent projects.


*** CONTACT ***

Post feedback, feature requests and bug reports on the project's sourceforge page, sourceforge.net/projects/aligner/, or email me at lfaligner@gmail.com. I'm interested in your feedback, bug reports and feature requests, but I can't promise to help with troubleshooting... read the program's output in the command line window and check the output files, especially the log. Most of the time, the problem should be pretty obvious, and possibly very easy to fix.

Shameless solicitation: register at Dropbox (and install the app) using the referral link https://www.dropbox.com/referrals/NTE2Mzc3OTUwOQ?src=global0 to get us both some free online storage space. Dropbox is a great free cloud backup/webhosting/file syncing service, you will probably like it. I will definitely like the extra space I get if you sign up and install the app :)

*** DISCLAIMER ***

The software is provided as is. I can't guarantee that this program will do what you want it to. I can't even guarantee that it does anything at all. I also can't guarantee that it won't do things you don't want it to, especially if you don't want it to do things like delete certain files from the folder named aligner. Read the readme (well, I guess you just have) and use at your own risk.
