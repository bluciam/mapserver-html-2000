#!/usr/bin/perl

# Force explicit decleration of all variables.
use strict;

# Begin the script
main();

# The main body
sub main {
  my(%frmFlds,$cmd,$long,$lat,$projParams,$projection,$Bstring,$landColor,$waterColor,$boundary,$debug);

  $debug = 1;

  get_Form_Data(\%frmFlds);

  # Check if xmin, xmax, ymin and ymax are valid
  if (!(($frmFlds{"xmin"} <= 360) && ($frmFlds{"xmin"} >= -180) &&
     ($frmFlds{"xmin"} =~ /^[-]?\d/) &&
     !(substr($frmFlds{"xmin"},1) =~ /\D/) &&
     ($frmFlds{"xmax"} <= 360) && ($frmFlds{"xmax"} >= -180) &&
     ($frmFlds{"xmax"} - $frmFlds{"xmin"}) && 
     ($frmFlds{"xmax"} =~ /^[-]?\d/) &&
     !(substr($frmFlds{"xmax"},1) =~ /\D/) &&
     (abs($frmFlds{"xmax"}-$frmFlds{"xmin"}) <= 360)) ||
     ($frmFlds{"xmax"} eq "") || ($frmFlds{"xmin"} eq "")){
        error("Please check that the longitude values are valid\n");
  }

  if (!(($frmFlds{"ymin"} <= 90) && ($frmFlds{"ymin"} >= -90) &&
     ($frmFlds{"ymin"} =~ /^[-]?\d/) &&
     !(substr($frmFlds{"ymin"},1) =~ /\D/) &&
     ($frmFlds{"ymax"} <= 90) && ($frmFlds{"ymax"} >= -90) &&
     ($frmFlds{"ymax"} =~ /^[-]?\d/) &&
     !(substr($frmFlds{"ymax"},1) =~ /\D/) &&
     ($frmFlds{"ymax"} - $frmFlds{"ymin"})) ||
     ($frmFlds{"ymax"} eq "") || ($frmFlds{"ymin"} eq "")){
        error("Please check that the latitude values are valid\n");
  }

  # Calculate the extra parameters of the projection
  $long = ($frmFlds{"xmin"}+$frmFlds{"xmax"})/2;
  $lat = ($frmFlds{"ymin"}+$frmFlds{"ymax"})/2;
  $projParams = "";
  if (($frmFlds{"proj"} eq "C") || ($frmFlds{"proj"} eq "E") ||
     ($frmFlds{"proj"} eq "S") || ($frmFlds{"proj"} eq "G")){
    $projParams = "$long\/$lat\/";
  }
  elsif ($frmFlds{"proj"} ne "M") {
    $projParams = "$long\/";
  }

  $projection = $frmFlds{"proj"};
  # Check whether Scale or Width is chosen
  if ($frmFlds{"SorW"} eq "Scale"){
    $projection =~ tr/A-Z/a-z/;
  }

  # Label Information
  $Bstring = "";

  if (($frmFlds{"grid"} ne "") && ($frmFlds{"grid"} >= 0)){
    if ($frmFlds{"grid"} =~ /\D/){
       error("Please check that the grid value is valid<BR>\nMust be a numerical value\n");
    }
    $Bstring="g".$frmFlds{"grid"}.$Bstring;

    if (($frmFlds{"frame"} ne "") && ($frmFlds{"frame"} >=0)) {
      if ($frmFlds{"frame"} =~ /\D/){
         error("Please check that the frame value is valid<BR>\nMust be a numerical value\n");
      }
      $Bstring="f".$frmFlds{"frame"}.$Bstring;
    }else{
      $Bstring="f".2*$frmFlds{"grid"}.$Bstring;
    }

    if (($frmFlds{"annot"} ne "") && ($frmFlds{"annot"} >= 0)){
      if ($frmFlds{"annot"} =~ /\D/){
         error("Please check that the annotation value is valid<BR>\nMust be a numerical value\n");
      }
      $Bstring = "-B".$frmFlds{"annot"}.$Bstring;
    }else{
      $Bstring="-B".2*$frmFlds{"grid"}.$Bstring;
    }
  }
  elsif (($frmFlds{"frame"} ne "") && ($frmFlds{"frame"} >= 0)){
    if ($frmFlds{"frame"} =~ /\D/){
       error("Please check that the frame value is valid<BR>\nMust be a numerical value\n");
    }
    $Bstring="f".$frmFlds{"frame"}.$Bstring;

    if (($frmFlds{"annot"} ne "") && ($frmFlds{"annot"} >= 0)){
      if ($frmFlds{"annot"} =~ /\D/){
         error("Please check that the annotation value is valid<BR>\nMust be a numerical value\n");
      }
      $Bstring = "-B".$frmFlds{"annot"}.$Bstring;
    }else{
      $Bstring="-B".$frmFlds{"frame"}.$Bstring;
    }
  }
  elsif (($frmFlds{"annot"} ne "") && ($frmFlds{"annot"} >= 0)){
    if ($frmFlds{"annot"} =~ /\D/){
       error("Please check that the annotation value is valid<BR>\nMust be a numerical value\n");
    }
    $Bstring="-B".$frmFlds{"annot"}.$Bstring;
  }
  else{
    # if ! (all "") then error
    if (!(($frmFlds{"annot"} eq "") && ($frmFlds{"frame"} eq "") &&
       ($frmFlds{"grid"} eq ""))){
       error("Check that frame, grid, and annotation have valid values.");
    }
  }

  if ($frmFlds{"title"} ne ""){
    $Bstring = (($Bstring eq "") ? "-B":$Bstring).":\.\"".$frmFlds{"title"}."\":";
    $Bstring =~ tr/"//;
  }

  # Land Color
  $landColor ="";
  if ($frmFlds{"lred"} ne ""){
    if (!(($frmFlds{"lred"} >=0) && ($frmFlds{"lred"} <=255) && 
         !($frmFlds{"lred"} =~ /\D/))){
      error("Please check your Land colour-Red entry. Must be 0 to 255");
    }
    $landColor = "-G".$frmFlds{"lred"};
    if ( ($frmFlds{"lgreen"} ne "") && ($frmFlds{"lblue"} ne "") ){
      if (!(($frmFlds{"lgreen"} >=0) && ($frmFlds{"lgreen"} <=255) && 
           !($frmFlds{"lgreen"} =~ /\D/))){
        error("Please check your Land colour-Green entry. Must be 0 to 255");
      }
      if (!(($frmFlds{"lblue"} >=0) && ($frmFlds{"lblue"} <=255) &&
           !($frmFlds{"lblue"} =~ /\D/))){
        error("Please check your Land colour-Blue entry. Must be 0 to 255");
      }
      $landColor .= "\/".$frmFlds{"lgreen"}."\/".$frmFlds{"lblue"};
    }
  }

  # Water Color
  $waterColor = "";
  if ($frmFlds{"wred"} ne ""){
    if (!(($frmFlds{"wred"} >=0) && ($frmFlds{"wred"} <=255) && 
         !($frmFlds{"wred"} =~ /\D/))){
      error("Please check your Water colour-Red entry. Must be 0 to 255");
    }
    $waterColor = "-S".$frmFlds{"wred"};
    if (($frmFlds{"wgreen"} ne "") && ($frmFlds{"wblue"} ne "") ){
      if (!(($frmFlds{"wgreen"} >=0) && ($frmFlds{"wgreen"} <=255) && 
           !($frmFlds{"wgreen"} =~ /\D/))){
        error("Please check your Water colour-Green entry. Must be 0 to 255");
      }
      if (!(($frmFlds{"wblue"} >=0) && ($frmFlds{"wblue"} <=255) && 
           !($frmFlds{"wblue"} =~ /\D/))){
        error("Please check your Water colour-Blue entry. Must be 0 to 255");
      }
      $waterColor .= "\/".$frmFlds{"wgreen"}."\/".$frmFlds{"wblue"};
    }
  }

  # Check if either Water and Land color exist  
  if (($waterColor eq "") && ($landColor eq "")){
    $landColor = "-W1";
  }

  # Check the Boundaries entry
  $boundary = "";
  if ($frmFlds{"Boundaries"} eq "National"){
    $boundary = "-N1";
  }
  elsif ($frmFlds{"Boundaries"} eq "State in the Americas"){
    $boundary = "-N2";
  }
  elsif ($frmFlds{"Boundaries"} eq "Marine"){
    $boundary = "-N3";
  }
  elsif ($frmFlds{"Boundaries"} eq "All of the above"){
    $boundary = "-Na";
  }

  $cmd = "pscoast -J$projection$projParams".$frmFlds{"valueSorW"}.
         " -R".$frmFlds{"xmin"}."\/".$frmFlds{"xmax"}."\/".$frmFlds{"ymin"}.
         "\/".$frmFlds{"ymax"}." $Bstring $landColor $waterColor ".
         "$boundary -U\"".$frmFlds{"Author"}."\" -P > map.ps;";

  # replace map.ps with date - remove all spaces

  # print HTML Header 
  print "Content-type: text/html\n\n";

  # For testing
  if ($debug){print ("$cmd\n");}

  # run gmt command
  system($cmd);
  
  # convert the output (ps file) in to image with the following: 
  # export PAPERSIZE=a2
  # pstoimg -crop a map.ps
  system("(setenv PAPERSIZE a2;/usr/local/bin/pstoimg -quiet -scale 1.4 -crop a map.ps)");

  # create the output in html:
  # png image in center with white backgroung and a back button 
  print "<HTML><TITLE>Your Map</TITLE><BODY bgcolor=white><CENTER><IMG SRC=\"map.png\"></CENTER></BODY></HTML>";
}

sub get_Form_Data {

  my($hashRef) = shift;
  my($buffer) = "";
  my($debug) = 0;

  if ($ENV{'REQUEST_METHOD'} eq 'GET') {
    $buffer = $ENV{'QUERY_STRING'};
  }
  else{
    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  }

  if ($debug){ print "Content-type: text/html\n\n$buffer\n";}

  foreach (split(/&/, $buffer)){
    my($key, $value) = split(/=/, $_);

    $key   = decode_URL($key);    
    $value = decode_URL($value);
    $value =~ s/(<P>\s*)+/<P>/g;   # compress multiple <P> tags.    
    $value =~ s/</&lt;/g;           # turn off all HTML tags.
    $value =~ s/>/&gt;/g;
    $value =~ s/&lt;b&gt;/<b>/ig;   # turn on the bold tag.    
    $value =~ s!&lt;/b&gt;!</b>!ig;
    $value =~ s/&lt;i&gt;/<b>/ig;   # turn on the italic tag.
    $value =~ s!&lt;/i&gt;!</b>!ig;
    $value =~ s!\cM!!g;            # Remove unneeded carriage re    
    $value =~ s!\n\n!<P>!g;        # Convert 2 newlines into para    
    $value =~ s!\n! !g;            # Convert newline into spaces.
    %{$hashRef}->{$key} = $value;
  }  
}

sub decode_URL {
  $_ = shift;
  tr/+/ /;
  s/%(..)/pack('c', hex($1))/eg;
  return($_);
}

sub error {
  print ("Content-type: text/html\n\n");
  print ("<HTML><BODY bgcolor=white><CENTER>\n<H1>Please Check your".
         " input</H1>\n<BR>\n<H2>@_</H2>\n</CENTER>\n<BR><HR>\n".
         "<A HREF=\"http://rosita.cse.unsw.edu.au:4950/interface.html\">[Back to the form]</A>".
         "</BODY></HTML>\n");
  exit 0;
}
