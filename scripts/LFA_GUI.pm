package LFA_GUIStdin;
our @ISA = qw[ Thread::Queue ];

sub TIEHANDLE { bless $_[1], $_[0]; }
sub READLINE { $_[0]->dequeue(); }

package LFA_GUIStdout;
our @ISA = qw[ Thread::Queue ];

sub TIEHANDLE { bless $_[1], $_[0]; }
sub PRINT  { $_[0]->enqueue( join ' ', @_[ 1 .. $#_ ] ); }
sub PRINTF { $_[0]->enqueue( sprintf $_[1], @_[ 2 .. $#_ ] ); }

package LFA_GUI;
use strict;
use warnings;
use threads;
use Thread::Queue;

my $Qin  = new Thread::Queue;
my $Qout = new Thread::Queue;

tie *STDIN,  'LFA_GUIStdin',  $Qin;
tie *STDOUT, 'LFA_GUIStdout', $Qout;



#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x

#TODO:

# sort langs alphabetically in lists

# scrolled frames don't fill the space properly despite expand and fill, so the GUI looks like crap

# dropdown list for all celex documents

# errormsg when doing 3-lang pdf:

 # Default button `Close' does not exist.
 # error:Tk::Frame=HASH(0x363cc04) is not a widget at LFA_GUI.pm line 602 thread 1
 # Tk::Error: Tk::Frame=HASH(0x363cc04) is not a widget at LFA_GUI.pm line 602 thread
 # 1
 # Tk::After::repeat at C:/Perl/site/lib/Tk/After.pm line 80
 # [repeat,[{},after#591,50,repeat,[\&LFA_GUI::__ANON__]]]
 # ("after" script)


# disable next button until a value is entered in all fields

# split-sentences.exe konzol nélküli verzió (pp --gui -o foo.exe bar.pl -x)
# segmenter msg

# file browse ablak cím

# , -font => [-slant => 'italic'] # this makes the font larger as well as italic; size weight (bold) slant (roman, italic) underline overstrike
# -font => "courier 12 bold italic" or -font => [-slant => "italic"]

# TMX langcode list supported by trados: http://msdn.microsoft.com/en-us/goglobal/bb896001.aspx

#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x#x




##################
# "GLOBAL" VARS: #
##################

my $tool;
my $version;
my $no = 2;					# number of languages (usually 2, so 2 is the default)
my @inputfile;			# array that holds the filepath of all input files of lf aligner
my @langs_iso;			# the two-letter ISO code of languages picked by the user; $tmx_langcode[x] is the language code used in the TMX
my $lang_1_iso_def;
my $lang_2_iso_def;
my @url;
my @langs_fullnames;	# the full names of languages picked by the user
my @line_no;			# line number of input files before/after segmentation
my @line_no_seg;			# line number of input files before/after segmentation
my @tmx_langcodes;
my $tmx_langcode_1_def;
my $tmx_langcode_2_def;
my %tmx_settings;



#######################
# LOAD LANGUAGE CODES #
#######################

my @langlist;		# Full list of all supported language names
my %langcodelookup;	# These can't be placed in the BEGIN block for some reason
my %langcodelookup_reverse;	# These can't be placed in the BEGIN block for some reason
BEGIN {
				# these will be the picklist entries in the language selection drop-down box
				@langlist = ("English","German","French","Spanish","Italian", #major languages first (repeated later in alphabetic list)
				"Abkhaz","Afar","Afrikaans","Akan","Albanian","Amharic","Arabic","Aragonese","Armenian","Assamese","Avaric","Avestan","Aymara","Azerbaijani","Bambara","Bashkir","Basque","Belarusian","Bengali","Bihari","Bislama","Bosnian","Breton","Bulgarian","Burmese","Catalan; Valencian","Chamorro","Chechen","Chichewa; Chewa; Nyanja","Chinese","Chuvash","Cornish","Corsican","Cree","Croatian","Czech","Danish","Divehi; Maldivian","Dutch","Dzongkha","English","Esperanto","Estonian","Ewe","Faroese","Fijian","Finnish","French","Fulah; Pular","Galician","Georgian","German","Greek (Modern)","Guaraní","Gujarati","Haitian; Haitian Creole","Hausa","Hebrew (modern)","Herero","Hindi","Hiri Motu","Hungarian","Interlingua","Indonesian","Interlingue","Irish","Igbo","Inupiaq","Ido","Icelandic","Italian","Inuktitut","Japanese","Javanese","Kalaallisut; Greenlandic","Kannada","Kanuri","Kashmiri","Kazakh","Khmer","Kikuyu","Kinyarwanda","Kyrgyz","Komi","Kongo","Korean","Kurdish","Kwanyama","Latin","Luxembourgish","Luganda","Limburgish","Lingala","Lao","Lithuanian","Luba-Katanga","Latvian","Manx","Macedonian","Malagasy","Malay","Malayalam","Maltese","Maori","Marathi","Marshallese","Mongolian","Nauru","Navajo","Norwegian Bokmal","North Ndebele","Nepali","Ndonga","Norwegian Nynorsk","Norwegian","Nuosu","South Ndebele","Occitan","Ojibwe","Old Church Slavonic; Old Bulgarian","Oromo","Oriya","Ossetian","Punjabi","Pali","Persian","Polish","Pashto","Portuguese","Quechua","Romansh","Kirundi","Romanian; Moldavian; Moldovan","Russian","Sanskrit","Sardinian","Sindhi","Northern Sami","Samoan","Sango","Serbian","Scottish Gaelic","Shona","Sinhalese","Slovak","Slovene","Somali","Southern Sotho","Spanish","Sundanese","Swahili","Swati","Swedish","Tamil","Telugu","Tajik","Thai","Tigrinya","Tibetan","Turkmen","Tagalog","Tswana","Tonga","Turkish","Tsonga","Tatar","Twi","Tahitian","Uyghur","Ukrainian","Urdu","Uzbek","Venda","Vietnamese","Volapuk","Walloon","Welsh","Wolof","Western Frisian","Xhosa","Yiddish","Yoruba","Zhuang","Zulu",);

				
				# this hash is for converting the language names to two-letter ISO codes; $langcodelookup{English} prints 'en' etc.
				%langcodelookup = ("Abkhaz" => "ab","Afar" => "aa","Afrikaans" => "af","Akan" => "ak","Albanian" => "sq","Amharic" => "am","Arabic" => "ar","Aragonese" => "an","Armenian" => "hy","Assamese" => "as","Avaric" => "av","Avestan" => "ae","Aymara" => "ay","Azerbaijani" => "az","Bambara" => "bm","Bashkir" => "ba","Basque" => "eu","Belarusian" => "be","Bengali" => "bn","Bihari" => "bh","Bislama" => "bi","Bosnian" => "bs","Breton" => "br","Bulgarian" => "bg","Burmese" => "my","Catalan; Valencian" => "ca","Chamorro" => "ch","Chechen" => "ce","Chichewa; Chewa; Nyanja" => "ny","Chinese" => "zh","Chuvash" => "cv","Cornish" => "kw","Corsican" => "co","Cree" => "cr","Croatian" => "hr","Czech" => "cs","Danish" => "da","Divehi; Maldivian" => "dv","Dutch" => "nl","Dzongkha" => "dz","English" => "en","Esperanto" => "eo","Estonian" => "et","Ewe" => "ee","Faroese" => "fo","Fijian" => "fj","Finnish" => "fi","French" => "fr","Fulah; Pular" => "ff","Galician" => "gl","Georgian" => "ka","German" => "de","Greek (Modern)" => "el","Guaraní" => "gn","Gujarati" => "gu","Haitian; Haitian Creole" => "ht","Hausa" => "ha","Hebrew (modern)" => "he","Herero" => "hz","Hindi" => "hi","Hiri Motu" => "ho","Hungarian" => "hu","Interlingua" => "ia","Indonesian" => "id","Interlingue" => "ie","Irish" => "ga","Igbo" => "ig","Inupiaq" => "ik","Ido" => "io","Icelandic" => "is","Italian" => "it","Inuktitut" => "iu","Japanese" => "ja","Javanese" => "jv","Kalaallisut; Greenlandic" => "kl","Kannada" => "kn","Kanuri" => "kr","Kashmiri" => "ks","Kazakh" => "kk","Khmer" => "km","Kikuyu" => "ki","Kinyarwanda" => "rw","Kyrgyz" => "ky","Komi" => "kv","Kongo" => "kg","Korean" => "ko","Kurdish" => "ku","Kwanyama" => "kj","Latin" => "la","Luxembourgish" => "lb","Luganda" => "lg","Limburgish" => "li","Lingala" => "ln","Lao" => "lo","Lithuanian" => "lt","Luba-Katanga" => "lu","Latvian" => "lv","Manx" => "gv","Macedonian" => "mk","Malagasy" => "mg","Malay" => "ms","Malayalam" => "ml","Maltese" => "mt","Maori" => "mi","Marathi" => "mr","Marshallese" => "mh","Mongolian" => "mn","Nauru" => "na","Navajo" => "nv","Norwegian Bokmal" => "nb","North Ndebele" => "nd","Nepali" => "ne","Ndonga" => "ng","Norwegian Nynorsk" => "nn","Norwegian" => "no","Nuosu" => "ii","South Ndebele" => "nr","Occitan" => "oc","Ojibwe" => "oj","Old Church Slavonic; Old Bulgarian" => "cu","Oromo" => "om","Oriya" => "or","Ossetian" => "os","Punjabi" => "pa","Pali" => "pi","Persian" => "fa","Polish" => "pl","Pashto" => "ps","Portuguese" => "pt","Quechua" => "qu","Romansh" => "rm","Kirundi" => "rn","Romanian; Moldavian; Moldovan" => "ro","Russian" => "ru","Sanskrit" => "sa","Sardinian" => "sc","Sindhi" => "sd","Northern Sami" => "se","Samoan" => "sm","Sango" => "sg","Serbian" => "sr","Scottish Gaelic" => "gd","Shona" => "sn","Sinhalese" => "si","Slovak" => "sk","Slovene" => "sl","Somali" => "so","Southern Sotho" => "st","Spanish" => "es","Sundanese" => "su","Swahili" => "sw","Swati" => "ss","Swedish" => "sv","Tamil" => "ta","Telugu" => "te","Tajik" => "tg","Thai" => "th","Tigrinya" => "ti","Tibetan" => "bo","Turkmen" => "tk","Tagalog" => "tl","Tswana" => "tn","Tonga" => "to","Turkish" => "tr","Tsonga" => "ts","Tatar" => "tt","Twi" => "tw","Tahitian" => "ty","Uyghur" => "ug","Ukrainian" => "uk","Urdu" => "ur","Uzbek" => "uz","Venda" => "ve","Vietnamese" => "vi","Volapuk" => "vo","Walloon" => "wa","Welsh" => "cy","Wolof" => "wo","Western Frisian" => "fy","Xhosa" => "xh","Yiddish" => "yi","Yoruba" => "yo","Zhuang" => "za","Zulu" => "zu");

				%langcodelookup_reverse = reverse %langcodelookup; # for reverse lookup, i.e. to get full language name from the two-letter language code
				
}
#################################





##############
# CREATE GUI #
##############


sub gui {
	require Tk;
	require Tk::Dialog;
	# require Tk::DialogBox;	# fancier dialog, I haven't used it so far
	require Tk::BrowseEntry;
	require Tk::Pane;			# for scrolled frames, see ...-> Scrolled('Frame' ...

	use utf8; # in case űíőó are used on labels (eg translations)

	my $mw = Tk::MainWindow->new;
	# $mw->minsize(450, 200);		# minimum size of main window in pixels
	$mw->minsize(500, 320);		# minimum size of main window in pixels


# debug window, disable for release
	# my $window2 = $mw -> Toplevel();
	# my $lb = $window2->Listbox( -width => 80, -height => 10 )->pack; #toggle to switch console on/off


	
	# my $ef = $mw->Entry( -width => 75, -takefocus => 1 )->pack( -side => 'left' );
	# my $enter = sub {$Qin->enqueue( $ef->get );$ef->delete(0, 'end' );1;};
	# my $do = $mw->Button( -text => 'go', -command => $enter)->pack( -after => $ef );
	# $ef->focus( -force );
	# $mw->bind( '<Return>', $enter );




	my $doStdout = sub {
		if( $Qout->pending ) {
			my $output = $Qout->dequeue;
			# $lb->insert( 'end', $output ) ;
			# $lb->see( 'end' );		# reloads the listbox and shows the last entries in case they hang off the end
			




#####################################################################################################################
# each elsif ( $output =~ /foo/) {} block contains a UI screen that is triggered by a STDOUT string in the main .pl #
#####################################################################################################################


################################################
			if ( $output =~ /Defaults: /) {	# $output always contains what the .pl printed to STDOUT (see my $output = $Qout->dequeue;)
			
			# if the gui is on, the main .pl prints the defaults that can't otherwise be grabbed, and we store them  global vars
			chomp $output;		# can't hurt, right?
			# $output =~ /lang_1_iso_def: ([^;]*); lang_2_iso_def: ([^;]*); tmx_langcode_1_def: ([^;]*); tmx_langcode_2_def: ([^;]*); creationid_def: ([^;]*)/;
			
			($lang_1_iso_def) = $output =~ /lang_1_iso_def: ([^;]*)/i;
			$lang_1_iso_def = $langcodelookup_reverse{$lang_1_iso_def};	# get a full language name from the two-letter code that's in the setup file
			
			($lang_2_iso_def) = $output =~ /lang_2_iso_def: ([^;]*)/i;
			$lang_2_iso_def = $langcodelookup_reverse{$lang_2_iso_def};
			
			($tmx_langcode_1_def) = $output =~ /tmx_langcode_1_def: ([^;]*)/i;
			
			($tmx_langcode_2_def) = $output =~ /tmx_langcode_2_def: ([^;]*)/i;
			
			($tmx_settings{creationid}) = $output =~ /creationid_def: ([^;]*)/i;

			
			($tool) = $output =~ /tool: ([^;]*)/i;
			
			($version) = $output =~ /version: ([^;]*)/i;


#####################################################################
# GUI ELEMENTS OF LF ALIGNER, SOME OF THEM SHARED BY THE TMX MAKER  #
#####################################################################

			} elsif ( $output =~ /FATAL ERROR!/ ) { # FATAL ERROR (printed by abort sub in main script), inform user of error before quitting
				$output =~ s/FATAL ERROR!//;
				$output =~ s/^\s+//;		# strip leading whitespace
				my $quit = $mw->Dialog(-title => 'ERROR!', 
				   -text => "The aligner has run into an error and needs to close.
				Reason: $output
				", 
				   -default_button => 'Close', -buttons => ['View log', 'Close'])->Show( );
				if ($quit eq 'Close') {
					$Qin->enqueue("");
				} elsif ($quit eq 'View log') {
									$Qin->enqueue("log");
			}



################################################
			} elsif ( $output =~ /try again!/i ){ # in case of wrong user input that can be fixed
			# } elsif ( $output =~ /(?:try again)|(?:SETUP FILE NOT FOUND)/i ){ #do doesn't work cuz setup is launched before the gui

				$mw->Dialog(	-title => 'Error', 
								-text => "$output", 
								-default_button => 'OK',
								-buttons => ['OK']
							)->Show( );


################################################
			} elsif ( $output =~ /t\/p\/h\/w\/c\/com\/epr\? \(Default:/ ) {
				$output =~ /Default: (.*)\)/;
				my $filetype = $1;


		# -borderwidth => 4, -relief => 'groove'
				my $frm_filetype = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');		# expand the frame's alloc rect to fill mw



				$frm_filetype -> Label(-text => "Please choose the type of your input files!", -font=>'bold')->pack (-pady => 10);

				my $rdb_t = $frm_filetype -> Radiobutton(-text=>"txt (UTF-8!), rtf, doc or docx file (see the readme!)", -value=>"t",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_p = $frm_filetype -> Radiobutton(-text=>"pdf, or pdf exported to txt (exporting works better, see readme!)", -value=>"p",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_h = $frm_filetype -> Radiobutton(-text=>"HTML file saved to your computer", -value=>"h",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_w = $frm_filetype -> Radiobutton(-text=>"webpage (you provide two URLs, the script does the rest)", -value=>"w",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_c = $frm_filetype -> Radiobutton(-text=>"EU legislation by CELEX number (will be downloaded automatically)", -value=>"c",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_com = $frm_filetype -> Radiobutton(-text=>"European Commission proposals (downloaded by year and number)", -value=>"com",  -variable=>\$filetype) -> pack(-anchor=> 'w');
				my $rdb_epr = $frm_filetype -> Radiobutton(-text=>"European Parliament reports (downloaded by year and number)", -value=>"epr",  -variable=>\$filetype) -> pack(-anchor=> 'w');


				my $buttnext = $frm_filetype -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $filetype );$frm_filetype->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );

				# my $butt_exit = $mw -> Button(-text=>"Abort", -command =>sub {$mw->destroy}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);



# my $beta = $mw->Dialog(-title => 'Beta info', 
				   # -text => "The graphical interface of LF Aligner is in beta. Features may be missing or buggy.\nSend comments, bug reports and feature requests to lfaligner\@gmail.com\nTo return to the command line interface, edit LF_aligner_setup.txt.", 
				   # -default_button => 'OK', -buttons => ['OK'])->Show( );

				my $frm_beta = $frm_filetype -> Frame(
														# -borderwidth => 4, -relief => 'groove'
													) -> pack(-expand => 1, -fill => 'both');

				my $betawarn = $frm_beta -> Label(-text => "Note: The graphical interface of LF Aligner is in beta. Some features may be missing or buggy.\nPlease send your comments, bug reports and feature requests to lfaligner\@gmail.com\nTo return to the command line interface, edit LF_aligner_setup.txt.\nCheck the sourceforge page regularly for updates.")->pack (-pady => 10);

# $frm_beta->configure(-bg=> 'Red');
# $betawarn->configure(-bg=> 'Red');




################################################
			}	elsif ( $output =~ /Provide a name for the output folder/ ) {
				my $folder;
				
				my $getfolder = sub {
					$folder = $mw->chooseDirectory(	-initialdir => '~',
												-title => 'Choose a folder',);
				};
				
				my $frm_folder = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				
				$frm_folder -> Label(-text => "Please choose the folder where your files will be saved!\n", -font=>'bold')->pack (-pady => 10);

				my $browse = $frm_folder -> Button( -text => 'Browse', -command => $getfolder)->pack();
				
				
				$frm_folder -> Label(-text => "\nNote: To create a new folder, overwrite the folder name in the entry field.\nThe path and the folder name can oly contain non-accented latin letters, numbers and a few symbols like _.",)->pack();
				
				my $buttnext = $frm_folder -> Button(
														-text=>"Next",
														-command =>sub {
																			$folder or $folder = "\n";
																			# if the user tacks on the folder name instead of overwriting the name in the editing field, you get existingfolder/existingfolder/newfolder; we fix that
																			if ( ($folder =~ /^(.*([\/\\][^\/\\]+)\2)+([\/\\][^\/\\]+)$/) && (!-d "$1") ) {
																				$folder =~ s@([/\\][^/\\]+)\1+([/\\][^/\\]+)$@$1$2@;
																			}
																			$Qin->enqueue( $folder );
																			$frm_folder->destroy;
																		}
														) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );
				
				
				
				# my $ef = $frm_folder->Entry( -width => 50, -takefocus => 1 )->pack( -side => 'left' );

				# my $enter = sub {
					# $Qin->enqueue( $ef->get );
					# $ef->delete(0, 'end' );
					# $frm_folder->destroy;
					# 1;
				# };
				# $mw->bind( '<Return>', $enter );	# can force focus here because it's on the entry field; bind the sub to enter instead
				# $ef->focus( -force );				# so the user can type right away




##########################################
			}	elsif ( $output =~ /Number of languages\?/ ) { #do only ask for number in case of TMX
				
				$langs_fullnames[0] = $lang_1_iso_def;	# defaults loaded by the .pl from the setup file and passed via STDOUT
				$langs_fullnames[1] = $lang_2_iso_def;
				$langs_fullnames[2] = "Spanish";	# hard-coded defaults
				$langs_fullnames[3] = "Italian";


				my $frm_langs_all;		# moved the declaration of these two in front of the sub
				my @frm_langs;


				# REDRAW THE WINDOW (to show language name entry boxes according to the current value of $no)
				my $apply_changeno = sub {	# we're using this workaround in the nested subs to avoid the "will not stay shared" error
					for (my $i = 0; $i < $no; $i++) {
						my $ii = $i;
						$ii++; # $ii is always $i + 1

						$langs_fullnames[$i] or $langs_fullnames[$i] = "English";	# English is the default
						$frm_langs[$i] = $frm_langs_all -> Frame() -> pack();		# a new frame for each browseentry box, no -expand => 1, -fill => 'both'
						# $frm_langs[$i] -> pack() if $tool =~ /align/i;
						
						# if $tool =~ /align/i
						
						
						my $langpicker = $frm_langs[$i] -> BrowseEntry(
							-label => "Language $ii: ",
							-state => 'readonly',				# this way the user can't type freely into the box
							-choices => \@langlist,
							-variable => \$langs_fullnames[$i],
						)->pack(-side => 'left');
					}
				}; # don't delete the ; - it is needed here (end of apply_changeno sub)




				# my $frm_getinfo = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				my $frm_getinfo = $mw -> Scrolled('Frame', -scrollbars => 'osoe') -> pack(-expand => 1, -fill => 'both'); #scrolled in case of small screen or many languages
				
				my $headertext;
				if ($tool =~ /align/i) {$headertext = "Specify the languages of your texts:\n"} else {$headertext = "Number of languages?\n"}
				$frm_getinfo-> Label(-text => $headertext, -font=>'bold')->pack (-pady => 10);

				my $frm_langs = $frm_getinfo -> Frame() -> pack(-expand => 1, -fill => 'both');

				my $frm_langs_no = $frm_langs -> Frame() -> pack(-expand => 1, -fill => 'both');

				my $changeno = $frm_langs_no -> BrowseEntry(
					-label => 'Number of languages (usually, 2): ',
					-variable => \$no,
					-width => 4,
					-browsecmd => sub {
						$frm_langs_all -> destroy; 							# remove old entry boxes
						$frm_langs_all = $frm_langs -> Frame();	# create the frame again
						$frm_langs_all -> pack(-expand => 1, -fill => 'both') if $tool =~ /align/i;		# do not display in TMX maker
						&$apply_changeno;
						}
				)->pack();# pack(-side => 'left');
				$changeno->insert('end', (2 .. 99));

				$frm_langs_all = $frm_langs -> Frame(); # frame so that we can destroy all the $frm_langs[$i] frames together
				$frm_langs_all -> pack(-expand => 1, -fill => 'both') if $tool =~ /align/i;		# do not display in TMX maker
				
				
				&$apply_changeno; # build entry boxes once when the window loads (rebuilt when $no is changed)
				
				
				$frm_getinfo -> Label(-text => "\nNote: you can change the default languages by editing LF_aligner_setup.txt",)-> pack if $tool =~ /align/i;		# do not display in TMX maker
				
				
				my $buttnext = $frm_getinfo->Button(-text => "Next", -command => sub {
																		$frm_getinfo->destroy;
																		for (my $i = 0; $i < $no; $i++) {
																			$langs_iso[$i] = $langcodelookup{$langs_fullnames[$i]} 
																		}
																		$Qin->enqueue($no);
																		# $Qin->enqueue(join (",", $no, @langs_iso)); # send $no and the lang list together in one string separated by ',' - the aligner will parse it
																		})-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);	#doesn't work, button not at bottom
				$buttnext -> focus (-force)
				
				# -side => 'bottom', 



#############################################
							} elsif ( $output =~ /Language (\d+)\?/ ) { # feed the language codes to the main script
				my $ii = $1;
				my $i = $ii - 1;
				$Qin->enqueue($langs_iso[$i]);	 # the language was picked previously, we just feed it to the .pl from the array here



#############################################
			} elsif ( $output =~ /CELEX number\?/ ) {

				my $frm_celex = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_celex -> Label(-text => "Enter the CELEX number!\n", -font => 'bold')->pack;
				
				my $frm_celex_entry = $frm_celex -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_celex_entry -> Label(-text => "CELEX number: ", -justify => 'left')->pack(-side => 'left');
				my $celexentry = $frm_celex_entry->Entry( -width => 20, -takefocus => 1 )->pack(-side => 'left');
				$celexentry->focus( -force );
				
				$frm_celex -> Label(-text => "\nNote: For regulations, directives and framework directives, you can simply\nenter R, D or FD, the year and number (the year always comes first!).\nE.g. 62003C0371, D 1996 34 or FD 2001 220",)->pack;
				
				
				my $next = sub {
							$Qin->enqueue($celexentry->get);
							$frm_celex->destroy;
				};
				
				
				$frm_celex->Button(-text => "Next", -command => $next)-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$mw->bind( '<Return>', $next );
				



#############################################
			} elsif ( $output =~ /Enter the year and number of the Commission proposal./ ) {
				my $year;
				my $number;
				
				my $frm_com = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_com -> Label(-text => "Enter the year and number of the Commission document!\n", -font => 'bold')->pack;
				
				
				$frm_com -> Label(-text => "Year: ", -justify => 'left')->pack (-side => 'left');
				
				my $comentry_yr = $frm_com->Entry( -width => 10, -textvariable => \$year, -takefocus => 1 )->pack (-side => 'left');
				$comentry_yr->focus( -force );
				$frm_com -> Label(-text => "Number: ", -justify => 'left')->pack (-side => 'left');
				my $comentry_nr = $frm_com->Entry( -width => 10, -textvariable => \$number, -takefocus => 1 )->pack (-side => 'left');


				# $frm_com -> Label(-text => "Note: ", -justify => 'left')->pack; # no note for COM
				
				
				my $next = sub {
							$Qin->enqueue($year . " " . $number);
							$frm_com->destroy;
				};
				
				
				$frm_com->Button(-text => "Next", -command => $next)-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$mw->bind( '<Return>', $next );
				




#############################################
			} elsif ( $output =~ /Enter the cycle, year and number of the EP report./ ) { #Enter the cycle, year and number of the EP report.
				my $cycle_year;
				my $number;
				
				my $frm_epr = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				my $frm_epr_entry = $frm_epr -> Frame(-borderwidth => 4,) -> pack(-expand => 1, -fill => 'both');
				
				
				$frm_epr_entry -> Label(-text => "Enter the cycle, year and number of the EP report.", -font => 'bold', -justify => 'left')->pack;
				
				
				$frm_epr_entry -> Label(-text => "Cycle and year (e.g. A7-2010): ", -justify => 'left')->pack (-side => 'left');
				my $comentry_yr = $frm_epr_entry -> Entry( -width => 10, -textvariable => \$cycle_year, -takefocus => 1 )->pack (-side => 'left');
				$comentry_yr->focus( -force );

				$frm_epr_entry -> Label(-text => "Number: ", -justify => 'left')->pack (-side => 'left');
				my $comentry_nr = $frm_epr_entry -> Entry( -width => 10, -textvariable => \$number, -takefocus => 1 )->pack (-side => 'left');
				
				
				$frm_epr -> Label(-text => "Note: The database only contains reports from 2003 on.",)->pack;
				
				
				my $next = sub {
							$Qin->enqueue($cycle_year . " " . $number);
							$frm_epr->destroy;
				};
				
				
				$frm_epr->Button(-text => "Next", -command => $next)-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$mw->bind( '<Return>', $next );
				


#############################################
			} elsif ( $output =~ /URL 1 \(..\)\?/ ) {
				my @frm_url;

				my $frm_web = $mw -> Scrolled('Frame', -scrollbars => 'osoe') -> pack(-expand => 1, -fill => 'both');
				$frm_web -> Label(-text => "Enter the URLs for webpage alignment", -font => 'bold', -justify => 'left')->pack;

				for (my $i = 0; $i < $no; $i++) {
					my $ii = $i +1; $ii++; # $ii is always $i + 1
					$frm_url[$i] = $frm_web -> Frame() -> pack(-expand => 1, -fill => 'both');
					$frm_url[$i] -> Label(-text=>"URL of $langs_fullnames[$i] page: ", -width => 30, -anchor => 'w')->pack(-side => 'left');
					my $entry_url = $frm_url[$i] -> Entry( -width => 70, -textvariable => \$url[$i],)->pack( -side => 'left' );
				}
				

				
				my $buttnext = $frm_web -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $url[0] );$frm_web->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );



#############################################
				} elsif ( $output =~ /URL (\d+) \(..\)\?/ ){ # languages 2 - $no
				my $ii = $1;
				my $i = $ii - 1;
				$Qin->enqueue( $url[$i] );
				


#do progress screen for print "\nDownloading file: $file[$i]; url: $url[$i]\n\n";


#############################################
			} elsif ( $output =~ /Drag and drop file 1/ ) { # this only triggers once, on the first file - we get all file paths at once and enqueue them later
																	# /Drag and drop file (\d+) \((..)\)/
				
				my $frm_inputfile_global = $mw -> Scrolled('Frame', -scrollbars => 'osoe') -> pack(-expand => 1, -fill => 'both');	# all the browse frames are inside this frame
				my @frm_inputfile;
				$frm_inputfile_global -> Label(-text => "Pick the input files!\n", -font=>'bold')->pack (-pady => 10);
				
				

				my @labeltext;
				my @buttbrowse;
				
				my $filepicker = sub {	# this sub is launched when the Browse button is pressed, see further down
					my $i = $_[0]; # $i is passed to the sub as an argument
					$inputfile[$i] = $mw ->getOpenFile(
								-title => "Please choose the $langs_fullnames[$i] file"
							);
					$labeltext[$i] = $inputfile[$i];		# autoupdated label
					$labeltext[$i] =~ s/^.*(.{40})$/...$1/ if $labeltext[$i] =~ /.{41}/;	# the full path may not fit
					$labeltext[$i] = "$langs_fullnames[$i] file: " . $labeltext[$i];
				}; # don't delete this ;
				
				
				for (my $i = 0; $i < $no; $i++) {
					my $ii = $i +1; $ii++; # $ii is always $i + 1
					$frm_inputfile[$i] = $frm_inputfile_global -> Frame() -> pack();	# -expand => 1, -fill => 'both'

					$labeltext[$i] = "$langs_fullnames[$i] file:\t– ";		# this will be displayed by the autoupdated label
					$buttbrowse[$i] = $frm_inputfile[$i] -> Button(-text=>"Browse", -command =>[\&$filepicker, $i]) -> pack(-side=> 'left');
					# this needs to be done in this roundabout way; command in sub outside of here, with $i passed as an argument (otherwise the other sub can't see $i), and the sub ref as a variable due to the nested subs problem
					$frm_inputfile[$i] -> Label(
													-textvariable => \$labeltext[$i],
													-width => 65,
													-anchor => 'w',
													# -justify => 'left', # this only seems to work with multiline text
												)->pack(-side => 'left'); 
				}
				#new the "same folder" limitation was removed as of ver 3.1
				# $frm_inputfile_global -> Label(-text => "
# Note: The files need to be in the same folder.", )->pack (-anchor => 'w');

				
				
				
				
				# enqueue the first file (we'll do the rest automatically)
				my $buttnext = $frm_inputfile_global -> Button(-text => "Next", -command => sub {
					my $filledin = 0;
					for (my $i = 0; $i < $no; $i++) {
						$filledin++ if ($inputfile[$i]);
					}
					if ($filledin eq $no ) {	# if all fields filled in, we go on
						$Qin->enqueue($inputfile[0]);$frm_inputfile_global->destroy;
					} else {					# warn if the user didn't pick all the files
							$mw->Dialog(-title => 'Error', 
				   -text => "Please pick a file in each language using the Browse button.", 
				   -default_button => 'OK', -buttons => ['OK'])->Show( );
					}
				})-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );



#############################################
							} elsif ( $output =~ /Drag and drop file (\d+)/ ) { # for files 2 to $no
				my $ii = $1;
				my $i = $ii - 1;
				$Qin->enqueue($inputfile[$i]);	 # the file was picked previously, we just feed it to the .pl here



#############################################
			} elsif ( $output =~ /Pdf to txt conversion done./i ){
				
				 my $frm_pdf = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				 
				 $frm_pdf -> Label(-text => "Pdf review", -font=>'bold')->pack (-pady => 10);
				 $frm_pdf -> Label(-text => "Press next when you're done with reviewing the converted pdf files, and you have closed them.",)->pack;

				my $reviewpdf = $mw->Dialog(-title => 'Review pdf', 
				   -text => "Pdf to txt conversion done. To get the best alignment results, review the txt files and remove any page headers/footers now, then save and close the files.", 
				   -default_button => 'Next', -buttons => ['View txt files', 'Next'])->Show( );
				if ($reviewpdf eq 'Next') {
					$Qin->enqueue("Move on.");
					$frm_pdf->destroy;
				} else {
					$Qin->enqueue("open");
				}


				my $buttnext = $frm_pdf -> Button(	-text=>"Next",
													-command =>sub {
																		$Qin->enqueue( "Move on." );
																		$frm_pdf->destroy;
																	}
												);
				$buttnext -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );



##############################################
			} elsif ( $output =~ /File (\d+).* (\d+) -> (\d+)/ ) { # capture the segment number stats for use later
my $ii= $1;
my $i = $ii - 1;
$line_no[$i] = $2;
$line_no_seg[$i] = $3;



##############################################
			} elsif ( $output =~ /Revert to unsegmented.*\? \(Default: (.)\)/ ) {
				# Revert to unsegmented [y/n]? (Default: n) 
				
				my $revert = $1; # set the default

				my $frm_revert = $mw -> Scrolled('Frame', -scrollbars => 'osoe') -> pack(-expand => 1, -fill => 'both');
				$frm_revert -> Label(-text => "Do you wish to revert to paragraph segmented files,
or use the sentence segmented versions?", -font=>'bold')->pack (-pady => 10);

				$frm_revert -> Label(-text => "Segment numbers before and after segmentation:",)->pack (-anchor => 'w');
				for (my $i = 0; $i < $no; $i++) { 
					$frm_revert -> Label(-text => "$langs_fullnames[$i]: $line_no[$i] -> $line_no_seg[$i]",)->pack (-anchor => 'w');
				}
				my $rdb_y = $frm_revert -> Radiobutton(-text=>"Yes, revert to the paragraph segmented versions", -value=>"y",  -variable=>\$revert) -> pack(-anchor=> 'w');
				my $rdb_n = $frm_revert -> Radiobutton(-text=>"No, the segmenting seems to have gone well, so I'll use the sentence segmented texts", -value=>"n",  -variable=>\$revert) -> pack(-anchor=> 'w');

					$frm_revert -> Label(-text => "
Note: you should revert to the paragraph segmented files if the segmentation
pushed the files badly out of balance (they had a similar number of segments before
but not after), especially if (one of) the files hardly gained any new segments.", )->pack (-anchor => 'w');


				my $buttnext = $frm_revert -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $revert );$frm_revert->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );




#############################################
				} elsif ( $output =~ /Clean up text\?/ ){ # review
				$output =~ /\(Default: (.)\)/;	# can't put this in the elsif line above, because the // can't span the \n in the output string
				my $cleanup = $1;				# set the default
				
				my $frm_cleanup = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_cleanup -> Label(-text => "Do you want to clean up the aligned file?", -font=>'bold')->pack (-pady => 10);
				
				
					my $rdb_y = $frm_cleanup -> Radiobutton(-text=>"Yes", -value=>"y",  -variable=>\$cleanup) -> pack(-anchor=> 'w');
					my $rdb_n = $frm_cleanup -> Radiobutton(-text=>"No", -value=>"n",  -variable=>\$cleanup) -> pack(-anchor=> 'w');

					
										$frm_cleanup -> Label(-text => "Note: cleanup means removing the ~~~ placed by Hunalign
at the boundaries of merged segments, and removing segment-starting \"- \".
In most cases, you should pick Yes.", )->pack (-anchor => 'w');


				my $buttnext = $frm_cleanup -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $cleanup );$frm_cleanup->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );
			



#############################################
				} elsif ( $output =~ /\[n\/t\/x\] \(Default: (.*)\)/ ){ # review
					# print "\n\nYou'll probably want to review the autoalignment now. You can put your notes (to be shown by your CAT as a text field when you get a concordance hit etc.) in the last column, replacing the note added by the aligner.\n";
		# print "\nDo you wish to:\nn  -  skip the review\nt  -  open the txt file for reviewing (e.g. for review with PlusTools;\n      save and close when you're done)\nx  -  create and open an xls\n      (only for files under 65500 segments; see instructions in xls)\n\n[n/t/x] (Default: $review_def) ";
				
				
				my $review = $1;	# set default
				

				my $frm_review = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_review -> Label(-text => "Review the aligned file to correct any incorrectly paired segments", -font=>'bold')->pack (-pady => 10);
				
				
					my $rdb_n = $frm_review -> Radiobutton(-text=>"No review", -value=>"n",  -variable=>\$review) -> pack(-anchor=> 'w');
					my $rdb_t = $frm_review -> Radiobutton(-text=>"Review a txt file (e.g. for review with PlusTools)", -value=>"t",  -variable=>\$review) -> pack(-anchor=> 'w');
					my $rdb_x = $frm_review -> Radiobutton(-text=>"Generate an xls and open it for reviewing", -value=>"x",  -variable=>\$review) -> pack(-anchor=> 'w');
					my $rdb_xn = $frm_review -> Radiobutton(-text=>"Generate an xls but do not open it", -value=>"xn",  -variable=>\$review) -> pack(-anchor=> 'w');


				my $buttnext = $frm_review -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $review );$frm_review->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );
				



################################################
			} elsif ( $output =~ /Append.write to / ) {
				my $tomastertm = "a";		# set default to "append"
				
				my $frm_mastertm = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_mastertm -> Label(-text => "Append to existing master TM file or overwrite it?", -font=>'bold')->pack (-pady => 10);

				my $rdb_t = $frm_mastertm -> Radiobutton(-text=>"Append", -value=>"a",  -variable=>\$tomastertm) -> pack(-anchor=> 'w');
				my $rdb_p = $frm_mastertm -> Radiobutton(-text=>"Overwrite", -value=>"o",  -variable=>\$tomastertm) -> pack(-anchor=> 'w');
				my $rdb_h = $frm_mastertm -> Radiobutton(-text=>"Don't write to master TM", -value=>"n",  -variable=>\$tomastertm) -> pack(-anchor=> 'w');

				my $buttnext = $frm_mastertm -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $tomastertm );$frm_mastertm->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );


############################################# #c
				} elsif ( $output =~ /Create TMX\?/ ){ # create TMX or not
				$output =~ /\(Default: (.)\)/;	# can't put this in the elsif line above, because the // can't span the \n in the output string
				my $create_tmx = $1;				# set the default
				
				my $frm_create_tmx = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_create_tmx -> Label(-text => "Do you want to generate a TMX file?", -font=>'bold')->pack (-pady => 10);
				
				
					my $rdb_y = $frm_create_tmx -> Radiobutton(-text=>"Yes", -value=>"y",  -variable=>\$create_tmx) -> pack(-anchor=> 'w');
					my $rdb_n = $frm_create_tmx -> Radiobutton(-text=>"No", -value=>"n",  -variable=>\$create_tmx) -> pack(-anchor=> 'w');

				$frm_create_tmx -> Label(-text => "\nNote: you'll need a TMX file if you wish to import your aligned texts into a CAT tool such as Trados", )->pack (-anchor => 'w');


				my $buttnext = $frm_create_tmx -> Button(-text=>"Next", -command =>sub {$Qin->enqueue( $create_tmx );$frm_create_tmx->destroy;}) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );
				


#############################################
				# } elsif ( $output =~ /Default tmx note: (.*)/ ){ # default note not available at startup with all other defaults because it' set by main script based on filenames etc.
				
				
				# $tmx_settings{note} = $1;
				# chomp $tmx_settings{note}; # can't hurt




#############################################
				} elsif ( $output =~ /Default creationdate: (.*Z)/ ){
				
				$tmx_settings{creationdate} = $1;
				chomp $tmx_settings{creationdate}; # can't hurt


#############################################
				} elsif ( $output =~ /Type the language code of language 1/ ){ # we'll ask for all the TMX settings in a single page here
				
				my $frm_tmx_settings = $mw -> Scrolled('Frame', -scrollbars => 'osoe') -> pack(-expand => 1, -fill => 'both');
				
				$frm_tmx_settings -> Label(-text => "Please provide the settings for the TMX file\n", -font=>'bold')->pack (-pady => 10);
				
				
				my $frm_tmx_settings_leftright = $frm_tmx_settings -> Frame() -> pack();
				
				my $frm_tmx_settings_left = $frm_tmx_settings_leftright -> Frame() -> pack(-side=>"left");
				my $frm_tmx_settings_right = $frm_tmx_settings_leftright -> Frame() -> pack(-side=>"left");
				
				
				for (my $i = 0; $i < $no; $i++) {
					$tmx_langcodes[$i] = uc($langs_iso[$i]);
				}
				
				# overwrite lang 1 and 2 with the defaults set in the setup.txt (if available)
				$tmx_langcodes[0] = $tmx_langcode_1_def if $tmx_langcode_1_def;
				$tmx_langcodes[1] = $tmx_langcode_2_def if $tmx_langcode_2_def;
				
				
				for (my $i = 0; $i < $no; $i++) {
					my $ii = $i +1; $ii++; # $ii is always $i + 1
					$frm_tmx_settings_left -> Label(-text=>"Language code for $langs_fullnames[$i]: ", -width => 36, -anchor => 'w')->pack(-anchor => 'w');
					$frm_tmx_settings_right -> Entry(-width => 10, -textvariable => \$tmx_langcodes[$i],)->pack(-anchor => 'w');
					
				}
				

# get TMX note (the string to be passed to the other thread is set when the Next button is pressed)

				my $frm_tmx_note = $frm_tmx_settings_left -> Frame() -> pack(-expand => 1, -fill => 'both');
				
				my $tmxnote_label = $frm_tmx_note -> Label(-text=>"Note:    ")->pack(-anchor => 'w', -side => 'left');
				
				my $tmxnote_entered;
				my $tmxnote_entry = $frm_tmx_settings_right -> Entry(-width => 25, -textvariable => \$tmxnote_entered, -state => 'disabled')->pack(-anchor => 'w',); # , -state => 'disabled'         -side => 'left',
				
				
				my $thirdcol_toggle = "on";
				my $thirdcol_button = $frm_tmx_note -> Checkbutton(
									# -text     => "Note to be added to each TU: ",
									-variable => \$thirdcol_toggle,
									-onvalue  => 'on',
									-offvalue => 'off',
									-command  => sub {
														# $tmxnote_label->configure( -state => $thirdcol_toggle);
														$tmxnote_entry->configure( -state => 'normal') if $thirdcol_toggle eq "off";
														$tmxnote_entry->configure( -state => 'disabled') if $thirdcol_toggle eq "on";
													},
									)->pack(-anchor => 'w', -side => 'left', ); # -before => $tmxnote_entry, 
				
				my $thirdcol_label = $frm_tmx_note -> Label(-text=>"Third column or: ")->pack(-anchor => 'w', -side => 'left'); # -before => $tmxnote_entry, 


				my $note_toggle = "normal";
				$frm_tmx_note -> Checkbutton(
									# -text     => "trapapapapa ",
									-variable => \$note_toggle,
									-onvalue  => 'normal',
									-offvalue => 'disabled',
									-command  => sub {
														$tmxnote_label->configure( -state => $note_toggle);
														$thirdcol_button->configure( -state => $note_toggle);
														$thirdcol_label->configure( -state => $note_toggle);
														$tmxnote_entry->configure( -state => $note_toggle) unless $thirdcol_toggle eq "on";
													},
									)->pack(-before => $tmxnote_label, -anchor => 'w', -side => 'left', ); # this does switch the $toggle to normal/disabled


				# my $frm_tmx_creationid = $frm_tmx_settings -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_tmx_settings_left -> Label(-text=>"Creator ID: ")->pack(-anchor => 'w');
				$frm_tmx_settings_right -> Entry( -width => 25, -textvariable => \$tmx_settings{creationid},)->pack(-anchor => 'w');
				
				

				# my $frm_tmx_creationdate = $frm_tmx_settings -> Frame() -> pack(-expand => 1, -fill => 'both');
				$frm_tmx_settings_left -> Label(-text=>"Creation date: ")->pack(-anchor => 'w');
				$frm_tmx_settings_right -> Entry( -width => 25, -textvariable => \$tmx_settings{creationdate},)->pack(-anchor => 'w');
				# malformed dates are ignored by the main script


				$frm_tmx_settings -> Label(-text => "\nNote 1: The \"Note\" field above refers to a text field added to each TU in your TMX.\n\"Third column\" means that the text in the third column of a bilingual file will be added as a note.\n To add a custom note text, uncheck Third column and type in the box.",)->pack (-anchor => 'w');

				
				$frm_tmx_settings -> Label(-text => "\nNote 2: CAT tools tend to be picky about what language codes they accept in TMX files.\nMany of them don't accept two-letter codes, i.e. you need to use EN-GB or EN-US instead of EN etc.\nIf in doubt, export a TM into TMX with the CAT tool you will be using and check the codes it uses.\nAlternatively, you can take a stab in the dark and hope for the best.",)->pack (-anchor => 'w');


				
				my $buttnext = $frm_tmx_settings -> Button(	-text=>"Next",
															-command =>sub {
																$Qin->enqueue( $tmx_langcodes[0] );
																# set $tmx_settings{note}
																if ($note_toggle eq "disabled") {$tmx_settings{note} = "none"} elsif ($thirdcol_toggle eq "on") {$tmx_settings{note} = ""} else {$tmx_settings{note} = $tmxnote_entered}
																
																$frm_tmx_settings->destroy;
																}
															) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );



#############################################
				} elsif ( $output =~ /Type the language code of language (\d+)/ ){ # languages 2 - $no
				my $ii = $1;
				my $i = $ii - 1;
				$Qin->enqueue( $tmx_langcodes[$i] );
				


#############################################
				} elsif ( $output =~ /date and time to be recorded in the TMX/ ){

				$Qin->enqueue("$tmx_settings{creationdate}"); #do add option to specify a date/time via $tmx_settings{creationdate}


#############################################
				} elsif ( $output =~ /the creator name you wish to be recorded in the TMX/ ){ 

				$Qin->enqueue("$tmx_settings{creationid}");


#############################################
				} elsif ( $output =~ /You can add a note to your TMX./ ){ 

# $tmx_settings{note} = "none" if $tmx_settings{note} eq ""; # this is now done in-place
				$Qin->enqueue("$tmx_settings{note}");


#############################################
				} elsif ( $output =~ /Press Enter to quit./i ){
				# when aborting, lf aligner prints "press enter to close this window", therefore we can use this string for recognizing normal termination

				$output =~ s/^\n+//s;

				# $written TUs have been written to the TMX. $skipped segments were skipped ($halfempty of them due to being half-empty).\n\nPress Enter to quit.\n";
				my $stats = "";
				if ($output =~ /have been written to the TMX/) {$output =~ /^(.*)\s*\n*Press Enter to quit.$/s;$stats = "$1";}
				
				my $quit = $mw->Dialog(	-title => "The end",
										-text => "The programme has terminated successfully.\n${stats}Click OK to exit.", 
										-default_button => 'OK', -buttons => ['OK'])->Show( );
				if ($quit eq 'OK') {
					$Qin->enqueue("Done");
				}


#############################################
#      GUI ELEMENTS OF THE TMX MAKER        #
#############################################
				} elsif ( $output =~ /Drag and drop the input file \(tab delimited txt/ ){ 




				my $frm_infiles = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');	# all the browse frames are inside this frame
				
				$frm_infiles -> Label(-text => "Pick the input files!\n", -font=>'bold')->pack (-pady => 10);
				
				
				my $frm_infiles_picker = $frm_infiles -> Frame() -> pack();
				
				my $labeltext;
				my @inputfiles;
				
				my $filepicker = sub {	# this sub is launched when the Browse button is pressed, see further down
				
				my $in_type = [	['Txt or Excel sheet', ['.txt', '.xls']],
								['All Files', '*']	];

				
				@inputfiles = $mw ->getOpenFile(
										-title => "Please choose the input file(s)",
										-filetypes => $in_type,
										-multiple => 1,
									);
									$labeltext = $inputfiles[0];										# this will be displayed by the autoupdated label
									$labeltext =~ s/^.*(.{40})$/...$1/ if $labeltext =~ /.{41}/;	# the full path may not fit
									my $fileno = @inputfiles;
									if ($fileno > 1) {
										$labeltext = "$no files chosen: " . $inputfiles[0];
									} else {
										$labeltext = "File chosen: " . $inputfiles[0];}
									}; # don't delete this ;
				
				
				

					$labeltext = "No file chosen";		# default of the autoupdated label
					my $buttbrowse = $frm_infiles_picker -> Button(-text=>"Browse", -command =>[\&$filepicker]) -> pack(-side=> 'left');
					# this needs to be done in this roundabout way; command in sub outside of here, with $i passed as an argument (otherwise the other sub can't see $i), and the sub ref as a variable due to the nested subs problem
					$frm_infiles_picker -> Label(
													-textvariable => \$labeltext,
													-width => 65,
													-anchor => 'w',
													# -justify => 'left', # this only seems to work with multiline text
												)->pack(-side => 'left'); 
				
				
				$frm_infiles -> Label(-text => "Note: input files can be UTF-8 txt or xls.\nYou may pick more than one file, they will be merged into the same TMX.")->pack (-pady => 30); # -pady => 10
				
				
				# enqueue the file path(s) when the Next button is clicked
				my $buttnext = $frm_infiles -> Button(-text => "Next", -command => sub {
					my $infilelist = join (";,;", @inputfiles); # ;,; is unlikely to occur in a file name
					if ($infilelist) {	# if at least one file has been picked, we go on
						$Qin->enqueue($infilelist);$frm_infiles->destroy;
					} else {					# warn if the user didn't pick all the files
							$mw->Dialog(-title => 'Error', 
						-text => "Please pick at least one input file.", 
						-default_button => 'OK', -buttons => ['OK'])->Show( );
					}
				})-> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				
				$buttnext->focus( -force );




#############################################
			} elsif ( $output =~ /Specify the path and name of the output file/i ){ 
				chomp $output;	# can't hurt
				
				my $frm_outfile = $mw -> Frame() -> pack(-expand => 1, -fill => 'both');
				my $frm_outfile_picker = $frm_outfile -> Frame() -> pack(-expand => 1, -fill => 'both');

				$frm_outfile_picker -> Label(-text => "Please specify the output file", -font=>'bold')->pack (-pady => 10);


				my $labeltext;
				my $outfile;
				
				($outfile) = $output =~ /Default: (.*)$/;
				
				my $filepicker = sub {	# this sub is launched when the Browse button is pressed, see further down
				
				my $out_type = [	['TMX', ['.tmx']],
								['All Files', '*']	];
				
				
				$outfile = $mw ->getSaveFile(
										-title => "Please choose the output file",
										-filetypes => $out_type,
										-defaultextension => "tmx",
									);
				
									$labeltext = $outfile;										# this will be displayed by the autoupdated label
									$labeltext =~ s/^.*(.{40})$/...$1/ if $labeltext =~ /.{41}/;	# the full path may not fit
									
										$labeltext = "Output file: $outfile";
									}; # don't delete this ;
				
				
				

					$labeltext = "Output file: $outfile";		# default of the autoupdated label
					my $buttbrowse = $frm_outfile_picker -> Button(-text=>"Browse", -command =>[\&$filepicker]) -> pack(-side=> 'left',-padx => 10);
					# this needs to be done in this roundabout way; command in sub outside of here, with $i passed as an argument (otherwise the other sub can't see $i), and the sub ref as a variable due to the nested subs problem
					$frm_outfile_picker -> Label(
													-textvariable => \$labeltext,
													-width => 65,
													-anchor => 'w',
													# -justify => 'left', # this only seems to work with multiline text
												)->pack(-side => 'left'); 
				


				$frm_outfile -> Label(-text => "Note: just press Next to create the output file\nin the same folder as the (last) output file, with the same name.")->pack (-pady => 30);


				my $buttnext = $frm_outfile -> Button(	-text=>"Next",
															-command =>sub {
																$Qin->enqueue( $outfile );
																# set $tmx_settings{note}
																$frm_outfile -> destroy;
																}
															) -> pack(-side => 'bottom', -anchor=> 'se', -padx => 3, -pady => 3);
				$buttnext->focus( -force );



#############################################
			} elsif ( $output =~ /already exists! Rename it or it will be overwritten/ ){ 
				my $exists = $mw->Dialog(	-title => 'Error', 
								-text => "$output", 
								-default_button => 'OK',
								-buttons => ['OK']
							)->Show( );
				
				if ($exists eq 'OK') {
					$Qin->enqueue("");
				}




# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
				}	# end of last elsif block
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

		}			# end of if( $Qout->pending )
	};				# end of dostdount sub

	$mw->repeat( 50, $doStdout ); # orig: 500

	Tk::MainLoop();
	exit(0);		# this terminates the other process when the GUI window is closed
}



1;