#!/usr/bin/perl
use English;
use strict;


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;; Constituency to Depedency Mapper
#;; Copyright (c) 2009-2012 Columbia University. All Rights Resereved.
#;; By Nizar Habash (habash@ccls.columbia.edu)  
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
# Last Edit: Aug 8, 2012 - extend rules for sub-conj S
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
# Last Edit: Feb 18, 2019 - forcing categories for empty NOMATCHEs
#



die "Usage: $0 config-file {verbose}? <stdin>\n" 
    if (@ARGV < 1);

my $config = $ARGV[0];
my $verbose=0;
if  ($ARGV[1] =~/verbose/i){$verbose=1;}
my %MAP=();
my $treecount=0;
my $readingtree = 0;
my $notdone = 1;
my @nodes=();
my @children=();
my @parentnum=();
my @content=();
my @inst=();
my @pos=();
my @relation=();
my @features=();
my $minnum=0;
my $maxnum=-1;
my $sen=0;
my %XDEP=();

my $xpcount=0;
my $xpmatch=0;
my $senfull=0;
my $currentmismatch=0;

&readMAP($config,\%MAP);

### Read dependency information

while (my $line=<STDIN>){

    if (${$MAP{"PARAM"}}{"sentence_number"}) { print "#SENTENCE $sen\n";}
    $sen++;
    $currentmismatch=0;
    &initialize;
    
    if (${$MAP{"PARAM"}}{"debug"}){print "$line\n";}

#Normalize POS to (POS WORD Features);


#BASIC MODIFICATION --> should move outside this code

    #print "$line\n";

#only SUB_CONJ An can behave like a PSEUDOVERBO... only 
#   3328 XXX (SBAR (SUB_CONJ An) (S (NP ... pseudoverb behavior in terms of case.... 
#   1420 XXX (SBAR (SUB_CONJ An) (S (VP ... An masdariya
# Other SUB_CONJ always head what follows as OBJ.

  ##  $line=~s/(\(SBAR\S*) (\(SUB\_CONJ [A><]n\)) \(S (\(\S+(SBJ|TPC))/$1 (S $2 $3/g;

#OLD    $line=~s/(\(SBAR\S*) (\(SUB\_CONJ [A><][ai]?n[^\)\s]*\)) \(S (\(\S+(SBJ|TPC))/$1 (S $2 $3/g;

    $line=~s/(\(SBAR\S*) (\(SUB\_CONJ \-?[A><][ai]?n[^\)\s]*\)) \(S (\(\S+(SBJ|TPC))/$1 (S $2 $3/g;

    $line=~s/(\(SBAR\S*) (\(SUB\_CONJ \-?[A><][ai]?n[^\)\s]*\)) \(S \(S (\(\S+(SBJ|TPC))/$1 (S (S $2 $3/g;
 

    #print ">>> $line\n";

=pod

ATB3
BEFORE	
3339	 (SBAR (SUB_CONJ An) (S (NP 
1655	 (SBAR (SUB_CONJ An) (S (VP 
614	 (SBAR (SUB_CONJ An) (S (S 
271	 (SBAR (SUB_CONJ An) (S (PUNC 
78	 (SBAR (SUB_CONJ An) (S (PP 
52	 (SBAR (SUB_CONJ An) (S (ADVP 
26	 (SBAR (SUB_CONJ An) (S (SBAR 
20	 (SBAR (SUB_CONJ An) (PUNC ") 
14	 (SBAR (SUB_CONJ An) (FRAG (NP 
3	 (SBAR (SUB_CONJ An) (UCP (S 
2	 (SBAR (SUB_CONJ An) (S (ADJP 
1	 (SQ (SUB_CONJ An) (VP (PRT 
1	 (SBAR (SUB_CONJ An) (SUB_CONJ An) 				
2	 (SBAR (SUB_CONJ An) (NP  				
3	 (SBAR (SUB_CONJ An) (FRAG  				
1	 (SBARQ (SUB_CONJ An) (S (VP 				
1	 (SBARQ (SUB_CONJ An) (S (NP 				
1	 (FRAG (SUB_CONJ An) (PUNC ") 				
1	 (FRAG (SUB_CONJ An) (NP (NP 				

AFTER					
1	 (FRAG (SUB_CONJ An) (NP (NP 			 	
1	 (FRAG (SUB_CONJ An) (PUNC ") 				
>>>changed
718	 (S (SUB_CONJ An) (NP-SBJ				
2607	 (S (SUB_CONJ An) (NP-TPC,SBJ			3364	
3	 (S (SUB_CONJ An) (S-NOM-SBJ			6085	0.55283484
10	 (S (SUB_CONJ An) (S-NOM-TPC				
26	 (S (SUB_CONJ An) (SBAR				
<<<changed
7	 (SBAR (SUB_CONJ An) (FRAG (NP 				
3	 (SBAR (SUB_CONJ An) (FRAG (NP-SBJ 
4	 (SBAR (SUB_CONJ An) (FRAG (NP-TPC 
1	 (SBAR (SUB_CONJ An) (FRAG (PUNC 
1	 (SBAR (SUB_CONJ An) (FRAG (SBAR 
1	 (SBAR (SUB_CONJ An) (FRAG (VP 
1	 (SBAR (SUB_CONJ An) (NP-SBJ
1	 (SBAR (SUB_CONJ An) (NP-TPC
20	 (SBAR (SUB_CONJ An) (PUNC ") 
2	 (SBAR (SUB_CONJ An) (S (ADJP-PRD 
11	 (SBAR (SUB_CONJ An) (S (ADVP-LOC-PRD 
41	 (SBAR (SUB_CONJ An) (S (ADVP-PRD 
1	 (SBAR (SUB_CONJ An) (S (NP 
13	 (SBAR (SUB_CONJ An) (S (NP-PRD 
1	 (SBAR (SUB_CONJ An) (S (NP-TMP-PRD 
78	 (SBAR (SUB_CONJ An) (S (PP-PRD 
271	 (SBAR (SUB_CONJ An) (S (PUNC 
601	 (SBAR (SUB_CONJ An) (S (S 
1655	 (SBAR (SUB_CONJ An) (S (VP 
1	 (SBAR (SUB_CONJ An) (SUB_CONJ An) 
3	 (SBAR (SUB_CONJ An) (UCP (S 
1	 (SBARQ (SUB_CONJ An) (S (VP 
1	 (SQ (SUB_CONJ An) (VP (PRT 

=cut    

    if ($verbose){print "$line\n";}
  
while ($line=~s/\(([^\)\(\s]+) ([^\)\(]+)\)/($1\#\#\#)/){
    my @item=split('·',$2);
    my ($gloss,$lexeme,$diac,$word)=();
    my $features="";


    $word=$item[0];
    $lexeme=$item[1];
    $lexeme=~s/[\[\]]//g;

    my $diac=$word;
    
    $word=~s/\+//g;

    if (($lexeme eq "clitics") 
	|| (($lexeme eq "nolemma")&&($word=~/^\-?(sa|ka|la|al|li|bi|fa|lA|li|wa|\>a|hA|hu|hum|hun\~a|humA|iy|ka|ki|kum|kumA|kun\~a|lA|mA|ma|nA|man|niy)\-?$/))
	|| (($lexeme =~/^(bi|li-)\_/)&&($word=~/^\-?(hA|hu|hum|hun\~a|humA|iy|ka|ki|kum|kumA|kun\~a|nA|niy)\-?$/))){
	
	if (($word=~/^\-?(sa|ka|la|al|li|bi|fa|lA|li|wa|\>a)\-$/)||($word=~/^(lA|mA)\-$/)){
	    $word=~s/\-//g;
	    $word=$word."+";
	}elsif ($word=~/^\-(hA|hu|hum|hun\~a|humA|iy|ka|ki|kum|kumA|kun\~a|lA|mA|ma|nA|man|niy)\-?$/){
	    $word=~s/\-//g;
	    $word="+".$word;
	}else{
	    #>n+ +>n+ ...
	    $word=~s/\-//g;
	}
	
    }
    
    if ($word !~/\-[LR]RB\-/){
	$word=~s/\-//g;
    }
    
    $word=~s/[aiuoFKN\`\~\_]//g;
    
    if ($word eq ""){ $word=$item[0];}

    
    $line=~s/\#\#\#/\#$word\#WORD:$diac\#LEXEME:$lexeme/;
    
}

$line=~s/\#/ /g;

    if ($verbose){ print "$line\n";}



#####################################################################
#GET NODES
my @nodetag=();
my @noderel=();
my $n=1;
while ($line=~s/\(([^\)\(\s\#]+) ([^\)\(\s\#]+) ([^\)\(\#]+)\)/\#$n/){
    #conversion of tags....
    my $pos=$1;
    my $word=$2;
    my $features=$3;

    $features=~s/\/\// /g;
  #  $features.=" TAG:$pos";
  #  $features.=" XTAG:$pos"; #used by handleXDEP
    
    my $complexpos=&getPOSTAG($pos,\%MAP);
    $pos=$complexpos."/".$pos;

    if ($pos=~/^DELETE/){  #Deleted node are not assigned a position.
	$line=~s/\#$n/DELETE/;
	#print "$word,$pos,$features\n";
    }else{
	&readdep($n,$word,$pos,0,"---",$features);
	
	$nodetag[$n]=$pos;
	$noderel[$n]="*";
	
	$n++;
    }
}
$line=~s/\#//g;

if (${$MAP{"PARAM"}}{"debug"}){print "1//  $line\n";}

#####################################################################

#step 1: modify constituents as needed
#step 2: for each XP identified:
    # - singleton ... easy
    # - try to process with rules
    # - else use backoff head perc.


#$line=&handleXDEP($line);
$line=&cleanwhitespace($line);

    
#   print "><><>$line\n";
# Resolve Index is done as part of deleting DELETE which is fired with POSTAG DELETE

#remove DELETEd nodes and keep track of indexes.
    my @INDEXMAP=();

while ($line=~s/\(([^\)\(\s]+)( DELETE)\)/DELETE/){
    my $XP=$1;
    my $index=0;
    my $dashtag="";
    if ($XP=~s/[\-\=](\d+)$//){$index=$1;}
    if ($XP=~/([^\(\s])-([a-zA-Z\-]+)$/){$dashtag=$2;}
    if (not exists $INDEXMAP[$index]){ $INDEXMAP[$index]="-$dashtag";}
    else{$INDEXMAP[$index].="-$dashtag";}
}

   


    $line=~s/ DELETE//g;

    if ($line eq "DELETE"){ # if all reduces to nothing!
	$line="";
    }

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;; Constituency to Depedency Mapper
#;; Copyright (c) 2010 Columbia University. All Rights Resereved.
#;; By Nizar Habash (habash@ccls.columbia.edu)  
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#print "---->$line\n";

##PREP XP --> should go in general map file



#    for (my $index=0; $index<@INDEXMAP; $index++){
#
#	if ($INDEXMAP[$index] ne ""){
#	    print "$index => $INDEXMAP[$index]\n";
#	}
#    }



##

while ($line=~s/\(([^\)\(\s]+)(( \d+)+)\)/\#\#\#/){
    my $XP=$1;
    my @ELEMENT=split('\s+',$2); shift @ELEMENT;
    my @headrules=();
    my $dashtag="";
    my $XPfeatures="";
    my $indextags="";
    if ($XP=~s/[\-\=](\d+)$//){
	my $index=$1;
	$XPfeatures.=" INDEX:$index"; 
	if (exists $INDEXMAP[$index]){
	    $indextags="$INDEXMAP[$index]";
	}
	#print "$index => $indextags\n";
    }
    if ($XP=~/([^\(\s])-([a-zA-Z\-]+)$/){
	$dashtag=$2;
	$XPfeatures.=" DASHTAG:$dashtag$indextags";
	$XP=~s/$dashtag$/$dashtag$indextags/;
    }


=pod

    if (${$MAP{"PARAM"}}{"debug"}){
      print ">> $line\n";
      print "ELEMENTS: $XP (@ELEMENT) ";
      for (my $i=0; $i<@ELEMENT;$i++){
	print "$nodetag[$ELEMENT[$i]] ";
      }
      print "\n";
      
      if (@ELEMENT>1){
	print "XELEMENTS: $XP -> ";
	for (my $i=0; $i<@ELEMENT;$i++){
	  print "$relation[$ELEMENT[$i]]:$nodetag[$ELEMENT[$i]]/$inst[$ELEMENT[$i]] ";
	}
	print "\n";
	
	print "IELEMENTS: $XP -> ";
	for (my $i=0; $i<@ELEMENT;$i++){
	  print "$inst[$ELEMENT[$i]] ";
	}
	print "\n";
      }
    }

=cut

    my $head=-1;


      #construct key for rule lookup
    my $key=$XP;
    my $seg="";
      for (my $i=0; $i<@ELEMENT;$i++){
	$key.= " ".($i+1).":".$nodetag[$ELEMENT[$i]]; #."/".$inst[$ELEMENT[$i]];
	$seg.= " ".$inst[$ELEMENT[$i]];  
      }

      #print "KEY $key\n";

      my $dep=&getGRAMAP($seg,$key,\%MAP);

      #print "GMAP#### $dep\n";#. ${$MAP{"GRAMAP"}}{$key}."\n";
      my @xp=();

      ($XP,@xp)=split('\s+',$dep);
      #print " $XP :: (@xp)\n";
	
      for (my $i=0; $i<@xp; $i++){
	my $xdepinfo=$xp[$i];
	#print "  [$xdepinfo]\n";
	if ($xdepinfo=~/^(\d+):(\d+),(\S+)$/){
	  $parentnum[$ELEMENT[$1-1]]=$ELEMENT[$2-1];
	  $relation[$ELEMENT[$1-1]]=$3;
	  #print "## $1 $parentnum[$ELEMENT[$1-1]] $relation[$ELEMENT[$1-1]]\n";
	}elsif ($xdepinfo=~/^(\d+):(-1)$/){
	  $parentnum[$ELEMENT[$1-1]]=0; 
	  $relation[$ELEMENT[$1-1]]="DEL";
	}elsif ($xdepinfo=~/^(\d+):0$/){
  my $pindex=$1;
    if($head ==-1){$head=$i;}
    #ONLY ONE HEAD ALLOWED.

    else{
      my $k = 2;
      my $parentid = $ELEMENT[$pindex-$k];

      while($parentnum[$ELEMENT[$pindex-$k]] == $ELEMENT[$pindex-1]) {
        $k++;
        $parentid = $ELEMENT[$pindex-$k];
      }

      $parentnum[$ELEMENT[$pindex-1]]=$ELEMENT[$pindex-$k];
      $relation[$ELEMENT[$pindex-1]]="MOD";
      if ($verbose){ print "Multiple roots detected. Reassigning.\n";}
      if($verbose){ print("Parent of $ELEMENT[$pindex-1] is now $parentid\n");}
    }

    #print "## head =$head => $ELEMENT[$head]\n";
	}
      }

     # &printdep;
   

  
    if (${$MAP{"PARAM"}}{"debug"}){ print "HEAD:$ELEMENT[$head] $nodetag[$ELEMENT[$head]] \n";}
    

    $nodetag[$ELEMENT[$head]]=$XP;
    $features[$ELEMENT[$head]].=" $XPfeatures";
    #$features[$ELEMENT[$head]]=~s/XTAG:\S+/XTAG:$XP/; #used by handleXDEP
    ##$relation[$ELEMENT[$head]]=$dashtag;
    
    $line=~s/\#\#\#/$ELEMENT[$head]/;

    if ($verbose){ print "$line\n";}
    
  }

#################################

  #  &TPC2SBJ;
  #  &modifydep_delete_NONE;
  #  &adjustAnChildren; #moves embedded TPC under AN up.
  #  #&raiseInitWaw;
  #  &fixPrepNOM;
  #  &insertDashRelations;
    #&catibposrel;
    
  #  if (${$MAP{"PARAM"}}{"delete_NONE"}){
  #    &modifydep_delete_NONE;
  #  }
    
    
    &printdep;
        
    if ($currentmismatch==0){
      $senfull++
    }else{
	if ($verbose){ print "MismatchCount [$currentmismatch]\t$sen\n";}
    }

  }

 if ($verbose){
printf "NOMATCH#######\tSents=%d\tSenPerfect=%d (%3.2f)\tXPCOUNT=%d\tXPMatch=%d (%3.2f)\n",$sen,$senfull,(100*$senfull/$sen),$xpcount,$xpmatch, (100*$xpmatch/$xpcount);

}


sub getGRAMAP {
  my ($seg,$seq,$MAP)=@_;
  #dashtag...

  my $size=split('\s+',$seg)-1;
  $xpcount++;
  if ($verbose){print "$sen\t$size\tgetGRAMAP\t$seq\t($seg)"; }

  my @seq=split(/\s+/,$seq);
  my @match=("");
  my @rules=();
  my %seen=();

  my $keyseq=$seq;
  $keyseq=~s/\d+://g;
  $keyseq=~s/\-\S+//g;
  $keyseq=~s/\/\S+//g;
  my @keyseq=split(/\s+/,$keyseq);
  my @temprules=();
  @rules=();

  if($verbose){print "\nKEY $keyseq[0]\n";}
  for (my $i=1; $i<@keyseq; $i++){
      $match[$i]="";
      # print "KEY $keyseq[0] $keyseq[$i]\n";
      if($verbose){print "\t$keyseq[$i]\n";}

      foreach my $rule (@{${$MAP{"GRAMAP"}}{"$keyseq[0] $keyseq[$i]"}},@{${$MAP{"GRAMAP"}}{"* $keyseq[$i]"}}) {
	$rule=~/^(\d+)\t/;
	$temprules[$1]=$rule;
#	  if (not $seen{"$rule"}){
#	      push @rules,$rule;
#	      $seen{"$rule"}=1;
#	  }
      }
  }

  foreach my $rule (@temprules){
    if ($rule ne ""){
      #print "\n$rule\n";
      $rule=~s/^\d+\t//;
      push @rules,$rule;
      
    }
  }
  
#  foreach my $rule (@rules){
#    print "\n$rule\n";
#  }



  if (&matchrules(\@seq,0,\@match,\@rules)){
      #print "YES (@match)\n";
      my $dep=join(" ",@match);
      if ($verbose){print "\t>>>> $dep\n";}
      $xpmatch++;
      return($dep);
  }elsif (($size==1)&&($seq=~/^(\S+) 1:[^\d]+$/)){
      #basic default head selection
      #This a default as opposed to a rule because in some cases we may want to change the XP (as in NP -> NP-ACC) or NP-DEM... and those can have a single head...
      #This default is not fired if the sequence is malformed.  (input not (S 1:0) as opposed to (S 1:VP).
      my $dep=$seq;
      $dep=~s/^(\S+) 1:[^0]+$/$1 1:0/;
      if ($verbose){print "\t>>>> DEFAULT-1: $dep\n";}
      $xpmatch++;
      return($dep);

  }else{

      # this if statement checks if the match list is completely empty, and copies the category from the original sequence if it is
      if ($match[0] eq ""){
        $seq=~/^(\S+)/;
        $match[0]="$1";
      }

      #my $dep=join(" ",@match);
      #print "\nXXX$dep =====>";
      my $dep=join(" ",&makedefault(@match));
      #print "$dep\n";
      if ($verbose){print "\t>>>> NOMATCH DEF: $dep \n";}
      $currentmismatch++;
      return($dep);
  }
  

}
 

sub makedefault {
    my (@match)=@_;
    my $head=1; #default

    for (my $i=1;$i<@match; $i++){
	if ($match[$i]=~/:0$/){
	    $head=$i;
	    last;
	}
    }
    for (my $i=1;$i<@match; $i++){
	if ($match[$i] eq ""){
	    if ($i==$head){
		$match[$i]="$i:0";
	    }else{
		$match[$i]="$i:$head,MOD";
	    }
	}
    }
    return(@match);
}



#some rule preprocessing can be done earlier to save time... also rule regex expansion...

sub matchrules {
    my ($seq,$cover,$match,$rules)=@_;
    
    my @seq=@$seq;     #input sequence

    if ($cover == @seq){      #$cover is # if tokens in @seq that are covered.
	#done!
	#print  "DONE\n";
	return(1);
    }else{
	my @rules=@$rules; #a list of all relevant rules
	my ($success,$newcover)=(0,0);

	foreach my $rule (@rules){
	  ($success,$newcover)=&matchrule($seq,$cover,$match,$rule);
	  #print "new cover = $newcover\n";
	  if (($success)&&($newcover>$cover)){
	    if(&matchrules($seq,$newcover,$match,$rules)){
	      return(1);
	    }else{
	      return(0);
	    }
	  }
	}
	return(0);
      }
  }

sub matchrule {

#    This function matches a rule to a sequence and an existing prtial match.
#    it returns:
#    - success, 0 or 1
#    - cover, how much of the sequence is covered after rule is applied
#    #- newmatch, the output


    my ($seq,$cover,$match,$rule)=@_;
    my @seq=@$seq;     #input sequence
    my @match=@$match; #output match
    my ($id,$l,$r)=split(/\t/,$rule);
    my (@l)=split(/\s+/,$l);
    my (@r)=split(/\s+/,$r);

    my @map=();
    my @changed=();
    

    if ((($cover>0)&&($rule=~/^M1/))||
	(($cover==0)&&($rule=~/^A/))||
	(@r>@seq)) { #if rule is too long... no point
      return(0);
    }

   ###!
  ### XXX print "  matchrule (@seq) :: (@match) == (@l)\n";



    #MATCH
    my $matched=0;

    
    my $lx=$l[0];
    $lx=~s/\d+://g;
    $lx=~s/ /\.\* /g;
    $lx=~s/$/\.\*/;
    $lx=~s/\_/\\\_/g;
    $lx=~s/\+/\\\+/g;
    $lx=~s/\$/\\\$/g;


    if ($seq[0]=~/^$lx/){
	$matched=1;
	
	my $match0=$r[0];
	$match0=~s/\*/$seq[0]/;
	
	if ($match[0] eq ""){
	    $match[0]=$match0;
	}elsif($match[0]!~/$match0/){ #allow partial match such as NP+ACC == NP
	    $matched=0;
	}
    }
    
    if ($matched){
	my $mode="elastic";
	my $i;
	my $j;
	my @map=();
	

	

	for ($i=1,$j=1; (($i<@l)&&($j<@seq)); ){
		#print "MATCH? $mode $j $i $seq[$j] $l[$i]\n";
	    
	    if ($l[$i] eq "^"){
		$mode="init";
		$i++;
	    }elsif ($l[$i] eq ".."){
		$mode="elastic";
		$i++;
	    }else{
		$lx=$l[$i];
		$lx=~s/(\d+)://;
		my $num=$1;
		my $headlx=0;

		if ($lx=~/!!/){
		    $headlx=1;
		}
		if ($lx eq "*"){
		    $lx=".*";
		}elsif ($lx ne "!!"){ #but can be !!XP
		    $lx=~s/!!//;
		    $lx=~s/ /\.\* /g;
		    $lx=~s/$/\.\*/;
		    $lx=~s/\_/\\\_/g;
		    $lx=~s/\+/\\\+/g;
		    $lx=~s/\$/\\\$/g;
		    $lx=~s/\//\\\//g;
		}
		#
		#print "??? $seq[$j]=~/$lx/\n";

		if ((($lx eq "!!")&&($match[$j]=~/:0$/))
		    ||(($headlx)&&($match[$j]=~/:0$/)&&($seq[$j]=~/\d:$lx/))
		    ||(($match[$j] eq "")&&($seq[$j]=~/\d:$lx/))){
		    if($verbose){print "MATCH-YES $j $num $l ====> $r[$num]\n";}
		    $match[$j]=$r[$num];

		    $changed[$j]=1;
		    $map[$num]=$j;

		    $i++; $j++;
		    $mode="basic";
		}else{
		    #print "MATCH-NO\n";
		    if ($mode eq "elastic"){
			$j++;
		    }else{
			last;
			}
		}
	    }
	}
	    
	if ($i<@l){
	    $matched=0;	 
	    return(0);
	}else{
	    #print "PASS\n";
	    my $newcover=0;
	    #adjusting match.
	    for (my $i=0; $i<@match; $i++){
		if ($changed[$i]){
		    $match[$i]=~s/^(\d+):/$map[$1]:/;
		    $match[$i]=~s/:(\d+),/:$map[$1],/;
        if($verbose){print "----------- $match[$i]\n";}
		}
		if ($match[$i] ne ""){$newcover++}
	    }

	    @{$match}=@match;
	    
	    return(1,$newcover);
	}
    }
}


sub matchruleOLD {
    my ($seq,$rule,$head)=@_;

    my ($l,$r)=split(/\t/,$rule);

    if ($verbose){print "  matchrule $seq $head == $rule\n";}

    my $matchinit=0;
    if ($l=~s/ \^ / /){
	$matchinit=1;
    }

    if ($head ne ""){
	$l=~s/\!\!/$head/;
    }elsif ($l=~/\!\!/){  # if rule expects a head to be passed and there is none... abort match.
	return(0);
    }


    $seq=~s/\d+://g;

    $l=~s/\d+://g;

    $l=~s/ \.\. / \(\\S\* )\*/g;
    $l=~s/ /\.\* /g;
    $l=~s/$/\.\*/;
    $l=~s/\_/\\\_/g;
    $l=~s/\+/\\\+/g;
    $l=~s/\$/\\\$/g;


    if ($verbose){print "!!matchrule $seq == $l\n";}

    
    if ((($matchinit)&&($seq=~/^$l/))||
	((not $matchinit))&&($seq=~/$l/)){
	return(1);
    }else{
	return(0);
    }
}




###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################


#RYAN FIX:
sub insertDashRelations {
    my $n=0;
    my $p=0;
    
    for ($n=0; $n<=$maxnum;$n++){
	if ($parentnum[$n] == 0){
	    $relation[$n] = "---";
	}

	my $mom = $parentnum[$n];
	if( $pos[$mom] =~/(NNP)/ &&
	    $pos[$n]   =~/(NNP)/ ) {
	    $relation[$n] = "---";
	}

    }
}





#====================================
sub handleXDEP {
  my ($line)=@_;
  
  while ($line=~s/ (\d+)/ XXXXXX/){
    my $d=$1;
    my $fullpos="";
    if ($features[$d]=~/XTAG:(\S+)/){
      $fullpos=$1;
    }
    $line=~s/ XXXXXX/ $fullpos:$d/g;
  }
while ($line=~s/\(((SBAR|NP|ADJP|ADVP|WHADJP|WHADVP|WHNP|WHPP|PRN|PRT|PUNC|CONJP|FRAG|INTJ|LST|NAC|LST|NX|X)\S*) ([^\)\(]+)\)/XXXXXX/){  #handled ok PP; bad VP
    my $np=$1;
    my $p=$3;
    my $original="(NOXDEP\#$np $p)";
    
    if ($verbose){print "#!!!$np $p\n";}
    if ($p=~/ /){
      
	my $keynp="$np";
	#(ignore dashtag in key only)
	$keynp=~s/\-.*//;
	
	
	my $pp="$keynp $p ";
	my $d=1;
	my @d=();
	while($pp=~s/ (\S+):(\d+) / $d:$1 /){
	  $d[$d]=$2;
	  $d++;
	}
	$pp=&cleanwhitespace($pp);
	if ($verbose){print "#$pp\n";}
		
	my $max=-1;
	my $maxmap="";
	my $k=1;
	foreach my $m (keys %{${$MAP{"GRAMAP"}}{"$pp"}}){
	  #print "#### $k\t$m = ${${$MAP{"GRAMAP"}}{$pp}}{$m} \n";
	  $k++;
	  if (${${$MAP{"GRAMAP"}}{$pp}}{$m}>$max){
	    $maxmap=$m;
	    $max=${${$MAP{"GRAMAP"}}{$pp}}{$m};
	  }
	}

	$maxmap=~s/(\d+)/$d[$1]/g;
	
	my $XDEPKEY="$keynp $p ";
	while($XDEPKEY=~s/ \S+:(\d+) / $1 /){}
	$XDEPKEY=&cleanwhitespace($XDEPKEY);
	 if ($verbose){print "#CHOICE: #$max [$XDEPKEY]=>[$maxmap]\n";}
	$XDEP{"$XDEPKEY"}=$maxmap;

	if ($max==-1){
	  $line=~s/XXXXXX/$original/;	 
	  if ($verbose){print "#XDEP=Nomatch $pp\n";}
	}else{
	  $line=~s/XXXXXX/(XDEP\#$np $p)/;
	  if ($verbose){print "#XDEP=Applied\n";}
	}
      }else{
	$line=~s/XXXXXX/$original/;
	if ($verbose){print "#XDEP=Singleton\n";}
      }
	
      }
      
      $line=~s/NOXDEP\#//g;

     # print "1>> $line\n";
  $line=~s/(\)+)/ $1/g;

  while($line=~s/ [\S]+:(\d+) / $1 /){}
 
  $line=~s/ \)/\)/g;
  if ($verbose){print "2>> $line\n";}

return($line);
}
#====================================


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;; Constituency to Depedency Mapper
#;; Copyright (c) 2010 Columbia University. All Rights Resereved.
#;; By Nizar Habash (habash@ccls.columbia.edu)  
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



sub isSUBC {
    my ($w)=@_;
    if ($w=~/^(bEdmA|bynmA|EndmA|HAlmA|ryvmA|TAlmA|fymA|klmA|lmA|mAlm|\>ynmA|rgm|kyfmA|mhmA|ky|lky|l|HtY|\<\*|mmA)$/){
	return (1);
    }else{ 
	return(0);
    }
}


sub isDVAN {
    my ($w)=@_;
    if ($w=~/^(mA|>lA)$/){
	return (1);
    }else{ 
	return(0);
    }
}


sub adjustAnChildren {
    my $n=0;
    my $p=0;

    #PROBLEM: AN tag is SUB_CONJ which cover three constructions:
    # >an/mA (masdariyya;deverbalizer) which heads a verb as OBJ
    # bEdmA ++ (which is SUBCONJ)
    # <in~a/>an~a which are Pseudo verbs [these must have a sbj]
    
    &recreateChildren;

   # print "in AN ADJUST\n";
  # &printdep(1);

    #move (An (PRD (SBJ) ) )) to (AN (PRD) (SBJ))
    # PRD can be -PRD or a VERB!
    #IN CASE OF (AN TPC SBJ PRD) => AN SBJ (SBJ PRD))


     for ($n=0; $n<=$maxnum;$n++){
	 if (($pos[$n] eq "AN")&&&isSUBC($inst[$n])){
	     $relation[$n] = "MOD";
	     $pos[$n] = "SUBCONJ";
	 }
     }

    for ($n=0; $n<=$maxnum;$n++){
	if (($relation[$n] =~/TPC/)
	    && (($relation[$parentnum[$n]] =~/PRD/)||($pos[$parentnum[$n]]=~/(VB|VBP|VBN|VBD)/))
	    && (($pos[$parentnum[$parentnum[$n]]] eq "AN"))){
	    $pos[$parentnum[$parentnum[$n]]]="PSEUDOVERB";
	}
    }
    &recreateChildren;

    for ($n=0; $n<=$maxnum;$n++){
	if (($relation[$n] =~/SBJ/)
	    && (($relation[$parentnum[$n]] =~/PRD/)||($pos[$parentnum[$n]]=~/(VB|VBP|VBN|VBD)/))
	    && ($n<$parentnum[$n]) #sbj before prd
	    && (($pos[$parentnum[$parentnum[$n]]] eq "AN"))){
	    $parentnum[$n]=$parentnum[$parentnum[$n]];
	}
    }
    &recreateChildren;


    #identify what is a Pseudoverb -- must have a SBJ.
    for ($n=0; $n<=$maxnum;$n++){
	if (($pos[$parentnum[$n]] eq "AN")&&($relation[$n] =~/SBJ/)){
	    $pos[$parentnum[$n]]="PSEUDOVERB";
	}
    }

    for ($n=0; $n<=$maxnum;$n++){
	if (($pos[$parentnum[$n]] eq "PSEUDOVERB")&&
	    ($relation[$n] !~ /SBJ/)){
	    $relation[$n]="PRD";

	}elsif (($pos[$parentnum[$n]] eq "AN")&&
	    ($relation[$n] =~ /PRD/)){
	    $relation[$n]="OBJ";
	}
    }
    
    #&printdep(1);


    for ($n=0; $n<=$maxnum;$n++){
	if (($pos[$n] eq "AN")||($pos[$n] eq "PSEUDOVERB")){

	    #print "[ $inst[$parentnum[$n]] $pos[$parentnum[$n]] ($relation[$n] $inst[$n] $pos[$n]\n";

	    
	    if (($relation[$n] !~ /SBJ/)&&($pos[$parentnum[$n]]=~/(VB|VBP|VBN|VBD|IN)/)){
		$relation[$n] = "OBJ";
	    }

	    if (($inst[$n]=~/^(An|>n|mA)$/)&&($pos[$parentnum[$n]]=~/NN/)){
		$relation[$n] = "IDAFA";
	    }

	    if ($relation[$n+1] =~ /TPC/){
		$parentnum[$n+1]=$n;
		$relation[$n+1] = "SBJ";
	    }
	    
	    #handling cases with DEMonstratives which make TPC not directly adjacent
	    if (($pos[$n+1] =~ /DEM/)&&($relation[$n+2] =~ /TPC/)){
		$parentnum[$n+2]=$n;
		$relation[$n+2] = "SBJ";
	    }
	    
	}
    }
    &recreateChildren;
}

sub TPC2SBJ {
    my $n=0;
    my $p=0;

    
    &recreateChildren;

    for ($n=0; $n<=$maxnum;$n++){
	#print "$n $features[$n] $pos[$n]\n";
	if ($relation[$n] eq "TPC"){
	    if ($features[$n]=~/(INDEX:\d+)/){
		my $index=$1;
		foreach my $m (@{$children[$parentnum[$n]]}){
		    #print "$m $n $features[$n] $features[$m]\n";
		    if (($n != $m)&&($features[$m]=~/$index/)){
			if ($relation[$m]=~/SBJ/){
			    $relation[$n]=$relation[$m];
			}else{
			    #stays topic...
			}
		    }
		}
	    }
	}
    }
    &recreateChildren;
}


 

sub fixPrepNOM {
    my $n=0;
    my $p=0;

    

     
    #special case of modified PREP->NOM

    for ($n=0; $n<=$maxnum;$n++){
	
	if ($pos[$parentnum[$n]] eq "IN"){
	    my $parentINST=$inst[$parentnum[$n]];
	    if ($parentINST=~/^([A\>]mAm|[A\<]vr|[A\<]zA\'|bEd|byn|tjAh|tHt|tlw|H\*w|Hwl|Hyn|xlf|Dmn|Eqb|Ebr|mE|End|fwr|fwq|qbl|qbyl|qbAlp|qrb|[A\>]mvAl|[A\>]vnA\'|Dd|TwAl|EwD|Hsb|wfq|gyr|swY|[>A]bdA|mEA|Albtp|mvl|\$bh|nHw|dwn|ldY|xlAl|wrA\'|HyAl|jrA\'|wsT|rgm|dAxl|xArj|zhA\')$/){
		$relation[$n]=~s/^.*POBJ.*$/IDAFA/;
		#print "XXX $parentINST $inst[$n] $relation[$n]\n";
	    }
	}
    }

    for ($n=0; $n<=$maxnum;$n++){
	if ($pos[$n] eq "IN"){
	    if ($inst[$n]=~/^([A\>]mAm|[A\<]vr|[A\<]zA\'|bEd|byn|tjAh|tHt|tlw|H\*w|Hwl|Hyn|xlf|Dmn|Eqb|Ebr|mE|End|fwr|fwq|qbl|qbyl|qbAlp|qrb|[A\>]mvAl|[A\>]vnA\'|Dd|TwAl|EwD|Hsb|wfq|gyr|swY|[>A]bdA|mEA|Albtp|mvl|\$bh|nHw|dwn|ldY|xlAl|wrA\'|HyAl|jrA\'|wsT|rgm|dAxl|xArj|zhA\')$/){
		$pos[$n]="NN";
	    }
	}
    }
}





sub raiseInitWaw {

    &recreateChildren;

    if ($pos[1] eq "CC"){
	
	my $X = $parentnum[1];
	my $Y = $parentnum[$parentnum[1]];
	$parentnum[$X]=1;
	$relation[$X]="OBJ";

	$parentnum[1]=$Y;
	
    }


    &recreateChildren;
}





sub modifydep_delete_NONE {
    my $n=0;
    my $p=0;

    
    &recreateChildren;
    for ($n=0; $n<=$maxnum;$n++){
	if ($pos[$n] eq "NONE"){
	    $p = $parentnum[$n];
	    $pos[$n]="DEL";
	    #$inst[$n]=~s/\/\// /g;
	    #$inst[$n]=~s/\bPOS:/TAG:/g;
	    #$features[$p]="$features[$p] $inst[$n]"; 
	    &deleteNode($n);
	    $n--;
	}
    }
    &recreateChildren;
}



#----------------------------------------------------------------

sub readLine{
    my ($line) = @_;
    my (@l);

    my $num;
    my $word;
    my $pos;
    my $parent;
    my $rel;
    my $features;
    my @features;

    ($num,$word,$pos,$parent,$rel,@features)=split('\s+',$line);

    $features=join(' ',@features);
    $features =~ s/\s*<\?>\s*/ /g;
    $features =~ s/^[\[\]\s]*//;
    $features =~ s/[\[\]\s]*$//;

    $word=~s/\\\*/\*/g;

    $word=~s/\@(\d+)$//;

    #$features =  "$features SENTPOS:$1";
    
    if (($parent eq "*")&&($num!=0)){$parent=0};
    
    $pos =~ s/[\&\<\>]//g;
    if ($pos eq "") {$pos = "*"}
 
    $features=~s/\#/+/g;
    $features=~s/\^/_/g;
    $word=~s/\#/+/g;
    $word=~s/\^/_/g;
    $pos=~s/\#/+/g;
    $pos=~s/\^/_/g;
    $features =~ s/\s+/ /g;
   
    #print "#### $num,$word,$pos,$parent,$rel,$features\n";

    &readdep($num,$word,$pos,$parent,$rel,$features);
}

####################################
sub modifydep2 {
    my $n=0;
    my $p=0;

    
    &recreateChildren;
    for ($n=0; $n<=$maxnum;$n++){
	if ($pos[$n] eq "FEAT"){
	    $p = $parentnum[$n];
	    $pos[$n]="DEL";
	    $inst[$n]=~s/\/\// /g;
	    $inst[$n]=~s/\bPOS:/TAG:/g;
	    $features[$p]="$features[$p] $inst[$n]"; 
	    &deleteNode($n);
	    $n--;
	}
    }
    &recreateChildren;
    for ($n=0; $n<=$maxnum;$n++){
	$relation[$n]=~tr/[a-z]/[A-Z]/;
    }
    for ($n=0; $n<=$maxnum;$n++){
	if ($features[$n]=~s/\bkey\d:(\S+)//){
	    $relation[$n]="$1";
	}
    }   
    for ($n=0; $n<=$maxnum;$n++){
	if ($relation[$n] eq "*"){
	    if ($features[$n]=~/\bDASHTAG:(\S+)/){
		$relation[$n]="$1";
	    }
	}   
    }
}




sub NUMCLASS{
    my ($x)=@_;

    $x=~s/\.\d+//;
    $x=~s/\d*(\d\d)$/$1/;
 
    $x=~s/[>]/A/g;
    $x=~s/[Y]/y/g;
    
    if ((($x>10)&&($x<99))
	||($x=~/(((AHd|AvnA|Avny|vlAvt|ArbEt|xmst|sbEt|vmAnyt|tsEt)(E\$r(p?)))|(E\$r|vlAv|ArbE|xms|st|sbE|vmAn|tsE)([wy]n))/)){
	return("TMZ");}
    else {return("IDAFA")};
}


########################################################
########################################################

sub readMAP {
    my ($file,$MAP)=@_;

    open (MAP,"$file")||die "Error: Can't read [$file]\n";

    my $line="";
    my %DEFVAR=();
    my $mode="NONE";
    my %SEEN=();
    my $rulenum=0;
    while ($line=<MAP>){
	chomp $line;
	
	if ($line=~/\#\#\#(\S+)\#\#\#/){
	    $mode=$1;
	}elsif (($line=~/^\s*$/)||($line=~/^;/)){
	    #ignore
	}elsif ($mode eq "PARAMS"){
	    my @l=split(/\s+/,$line);
	    ${$$MAP{"PARAM"}}{$l[0]}=$l[2];
	}elsif ($mode eq "TAGMAP"){
	    my @l=split(/\s+/,$line);
	    
	    $l[2]=~s/\_/\\\_/g;
	    $l[2]=~s/\+/\\\+/g;
	    $l[2]=~s/\*/.*/g;

	    ${$$MAP{"TAG"}}{$l[2]}="$l[0]/$l[1]";
	    push @{$$MAP{"TAGORDER"}},$l[2];
	}elsif ($mode eq "HEADRULES"){
	    my ($XP,@l)=split('\s+',$line); 
	    my $dir="c";
	    foreach my $l (@l){
		if ($l=~/^\(([lr])\)$/){ push @{${$$MAP{"HEAD"}}{$XP}}, "$1 *"; }
		elsif ($l=~/^\(([lr])$/){ $dir=$1;}
		else { $l=~s/\)//;
		       if ($l!~/\s+/){ push @{${$$MAP{"HEAD"}}{$XP}}, "$dir $l"; }
		}
	    }
	}elsif ($mode eq "GRAMAP"){
	    ##DEFINE @XP@ (NP|VP|ADJP)
	    if ($line=~/^DEFINE\s+(\@[^\s\@]+\@)\s+(\S+)/){
		$DEFVAR{$1}=$2;
	    }else{
		
		while ($line=~s/(\@[^\s\@]+\@)/XX-DEFVAR-XX/){
		    my $var=$1;
		    if (not exists $DEFVAR{$var}){
			die "Unknown variable [$var]\n";
		    }else{
			$var=$DEFVAR{$var};
			$line=~s/XX-DEFVAR-XX/$var/;
		    }
		}
		

		if ($line=~/^\s*(\S+)\s*(.*)\s*=>\s*(.*)\s*/){
		    my $id=$1;
		    my $l=$2;
		    my $r=$3;
		    
		    $l=&cleanwhitespace($l);
		    $r=&cleanwhitespace($r);
		    
		    $rulenum++;

		    #organize map keys on XP ; on XP+child
		    
		    $l=~/^\s*(\S+)\s+(.*)\s*/;
		    my ($XPkeys,$childkeys)=($1,$2);
		    
		    #print "ORGANIZE:# ($XPkeys,$childkeys) \n";
		  		    
		    $XPkeys=~s/[\(\)]//g;
		    $XPkeys=~s/\|/ /g;
		    $XPkeys=~s/\d+://g;
		    $XPkeys=~s/\-\S+//g;
		    $XPkeys=~s/\/\S+//g;
		    
		    $childkeys=~s/[\(\)]//g;
		    $childkeys=~s/\|/ /g;
		    $childkeys=~s/\d+://g;
		    $childkeys=~s/\-\S+//g;
		    $childkeys=~s/\/\S+//g;

		    my @XPkey=split(/\s+/,$XPkeys);
		    my @childkey=split(/\s+/,$childkeys);
		    
		    foreach my $xpk (@XPkey){
			foreach my $ck (@childkey){
			    if (not $SEEN{"$xpk $ck :: $id $l $r"}){
				push @{${$$MAP{"GRAMAP"}}{"$xpk $ck"}},"$rulenum\t$id\t$l\t$r";
				#print "$xpk $ck ----> $l\t$r\n";
				$SEEN{"$xpk $ck :: $id $l $r"}=1;
			    }
			}
		    }
		    
		}else{
		    print STDERR "unrecognized line: $line\n";
		}
	    }
	}else{
	    print STDERR "unrecognized mode: $mode\n";
	}
    }
    close(MAP);
    
}


    
sub getPOSTAG {
    my ($pos,$MAP)=@_;
    
    my $posout="UNK";

    if (exists $$MAP{"TAG"}{$pos}){
	$posout=$$MAP{"TAG"}{$pos};
    }else{
	foreach my $tag (@{$$MAP{"TAGORDER"}}) {
	    if ($pos=~/^$tag$/){
		$posout=$$MAP{"TAG"}{$tag};
		last;
	    }
	}
    }

    return($posout);
}



#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
# GENERAL FUNCTIONS
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------

sub unique {
    my (@l)=@_;
    my %l=();
    foreach my $l (@l){$l{$l}=1;}
    return (keys %l);
}


sub cleanwhitespace {
    my ($l1)=@_;
    $l1 =~ s/^\s*//; $l1 =~ s/\s*$//; $l1 =~ s/\s+/ /g;
    return($l1);
}

#----------------------------------------------------------------


sub printdep {
    my $out ="";
    my $start=$minnum;
    if (not ${$MAP{"PARAM"}}{"print_root"}){ $start = 1}
    if (${$MAP{"PARAM"}}{"tree_tag"}){ print "<tree>\n";}

    
    for (my $i=$start;$i<=$maxnum;$i++){
	$features[$i].=" $pos[$i]";

	$pos[$i]=~s/^([^\/]+).*/$1/;

	#temporary:
	#$features[$i]="";
	$features[$i]=~s/\s+/ /g;
	$features[$i]=~s/\s+$//;
	$features[$i]=~s/,/<COMMA>/g;
	$features[$i]=~s/\s+/,/g;

	
	if ($inst[$i] ne ""){
	    if (${$MAP{"PARAM"}}{"show_features"}){
		$out = "$i $inst[$i] $pos[$i] $parentnum[$i] $relation[$i] \[$features[$i]\]";
	    }else{
		$out = "$i $inst[$i] $pos[$i] $parentnum[$i] $relation[$i]";
	    }
	}else{
	    if (${$MAP{"PARAM"}}{"show_features"}){
		$out = "$i root * * * \[\]";
	    }else{
		$out = "$i root * * *";
	    }
	}
	$out =~ s/\s+/\t/g;
	print "$out\n";
    }

    if (${$MAP{"PARAM"}}{"tree_tag"}){print "<\/tree>\n";}
    else{print "\n";}
    $treecount++;
}

#----------------------------------------------------------------
sub initialize {
    $notdone = 1;
    @nodes=();
    @children=();
    @parentnum=();
    @content=();
    @inst=();
    @pos=();
    @relation=();
    $minnum=0;
    $maxnum=-1;
    @features=();
}   
#----------------------------------------------------------------

sub readdep {
    my ($num,$node,$pos,$parent,$rel,$features) = @_;

    if ($num>$maxnum) {$maxnum=$num};	
    $inst[$num] = $node;
    $pos[$num] = $pos;
    $parentnum[$num] = $parent;
    
    if ($parentnum[$num] ne "*") {
	push @{$children[$parentnum[$num]]}, $num;
    }
    
    $relation[$num] = $rel;
    $features[$num] = $features;
}
#----------------------------------------------------------------

sub recreateChildren {
    my $c;
    @children=();
    for ($c=$minnum;$c<=$maxnum;$c++){
	if ($parentnum[$c] ne "*") {
	    unshift(@{$children[$parentnum[$c]]},$c);
	}
    }
}
#----------------------------------------------------------------

sub getFeatures {
    #$select ::= <feat-key>{|<feat-key}*
    my ($selcet,$features)=@_;
    my $s;
    my $f;
    my @sel=();
    my @flist=();
    my $new;
    
    $new="";
    @sel=split('\|',$selcet);
    @flist=split(' ',$features);

     for ($s=0; $s<@sel; $s++){
	for ($f=0; $f<@flist; $f++){
	    if ($flist[$f] =~ /^$sel[$s]/){
		$new="$new $flist[$f]";
	    }
	}
    }
    $new =~ s/^\s+//;

    return($new);
}

#----------------------------------------------------------------

sub moveFeatures {
    #$select ::= <feat-key>{|<feat-key}*
    my ($selcet,$source,$target)=@_;
    my $add;
    my $s;
    my $f;
    my @sel=();
    my @flist=();
    my $new;

    $new="";
    @sel=split('\|',$selcet);
    my @sflist=split(' ',$features[$source]);
    my @tflist=split(' ',$features[$target]);

    #take all unspecified features from target
    for ($f=0; $f<@tflist; $f++){
	$add=1;
	for ($s=0; $s<@sel; $s++){
	    if ($tflist[$f] =~ /^$sel[$s]/){
		$add=0;
	    }
	}
	if ($add){ $new="$new $tflist[$f]";}
    }

    #take all specified features from source
    for ($s=0; $s<@sel; $s++){
	for ($f=0; $f<@sflist; $f++){
	    if ($sflist[$f] =~ /^$sel[$s]/){
		$new="$new $sflist[$f]";
	    }
	}
    }
    $features[$target]=$new;
}

#----------------------------------------------------------------

sub insertNode {
    my ($num,$node,$pos,$parent,$rel,$features) = @_;
    my $i=0;

    for ($i=$maxnum,$maxnum++; $i>=0; $i--){
	if ($parentnum[$i]>=$num){$parentnum[$i]++;}

	if($i>=$num){
	    $inst[$i+1]=$inst[$i];
	    $pos[$i+1]=$pos[$i];
	    $parentnum[$i+1] = $parentnum[$i];
	    $relation[$i+1] = $relation[$i];
	    $features[$i+1] = $features[$i]
	    }
	
	if ($i==$num){
	    if ($parent>=$num){$parent++;}
	    &readdep($num,$node,$pos,$parent,$rel,$features);
	}
    }
    &recreateChildren;
}

#----------------------------------------------------------------

sub deleteNode {
    my ($num) = @_;
    my $i=0;
    my $withchild=0;
    
    # RYAN FIX:
    my $deletedNodeParent = $parentnum[$num];


    for ($i=0; $i<=$maxnum; $i++){
	if ($parentnum[$i]==$num){$withchild++;}
    }
    
    if (($num != 0)||($withchild!=0)) {   #just ignore any calls to delete root! or nodes with children

	for ($i=1; $i<$maxnum; $i++){
	    
	    if($i>=$num){ 
		$inst[$i]=$inst[$i+1];
		$pos[$i]=$pos[$i+1];
		$parentnum[$i] = $parentnum[$i+1];
		$relation[$i] = $relation[$i+1];
		$features[$i] = $features[$i+1]
		}

	    if ($parentnum[$i]>$num){
		$parentnum[$i]--; 
	    }
	    elsif ($parentnum[$i] == $num )  {  ## RYAN FIX:  If a node was a child of a deleted node,
		$parentnum[$i] = $deletedNodeParent;   # Replace its parent number with deleted node's parent number
		if( $deletedNodeParent > $num ) {
		    $parentnum[$i]--;
		}
	    }
	}
	&recreateChildren;
	$maxnum--;
    }
}

#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------





########################## DROP!!
=pod


sub catibposrel {
    my $n=0;
    my $p=0;
    
#    &recreateChildren;
    for ($n=1; $n<=$maxnum;$n++){
	if (${$MAP{"PARAM"}}{"debug"}){
	    $pos[$n] = &catibPOS($pos[$n],$inst[$n]) . "/" .$pos[$n];
	    $relation[$n] = &catibREL($relation[$n]) . "/". $relation[$n];
	}else{
	    $pos[$n] = &catibPOS($pos[$n],$inst[$n]);
	    $relation[$n] = &catibREL($relation[$n]);
	}	
    }
}

sub catibPOS {
    my ($pos)=@_;
  
    if ($pos=~/^NONE$/){
	return("NONE");
    }elsif ($pos=~/^(\,|\.|\:|\"|\-[LR]RB\-|PUNC|NUMERIC\_COMMA|NUM|NON\_ALPHABETIC)$/){
	return("PNX");
    }elsif($pos=~/^(DT\+NNP|DT\+NNPS|NNP|NNPS|ABBREV)$/){
	return("PROP");
    }elsif($pos=~/^(VB|VBD|VBP)$/){
	return("VRB");
    }elsif($pos=~/^(VBN)$/){
	return("VRB-PASS");
    }elsif($pos=~/^(CC|DT|IN|RP|AN|PSEUDOVERB|SUBCONJ)$/){  #AN=SUB_CONJ
	return("PRT");
    }else{
	return("NOM");
    }



}




sub catibREL {
    my ($rel)=@_;
    #the order is important --> SBJ-IDAFA (under DV is realized as IDF)

    if($rel=~/IDAFA/){
	return("IDF");
    }elsif ($rel=~/(SBJ)/){
	return("SBJ");
    }elsif($rel=~/CONJ|OBJ|POBJ/){
	return("OBJ");
    }elsif($rel=~/TPC/){
	return("TPC");
    }elsif($rel=~/PRD/){
	return("PRD");
    }elsif($rel=~/TMZ/){
	return("TMZ");
    }elsif($rel=~/\-\-\-/){
	return("---");
    }else{
	return("MOD");
    }	

}



    if (${$MAP{"PARAM"}}{"CATiB"}) {
#flatten QP

#solution #1
#$line=~s/\(QP((\s+\d+)+)\)/$1/g;
#$line=~s/\s+/ /g;


#solution 2, make QP chained
    # (NP (QP 1 2) 3 4) => (NP 1 (NP 2 (NP 3 4)))
    # this results in an "IDAFA" default! that has to be rewritten
#print "$line\n";
#inconsistent:
#(NP (QP (NUM 25) (PREP fy)) (NP (DET+NOUN+NSUFF_FEM_SG+CASE_DEF_GEN Alm}p)))
#(NP (QP (NUM 35) (PREP fy)) (DET+NOUN+NSUFF_FEM_SG+CASE_DEF_GEN Alm}p))
# (NP (QP 100 mtr mkEb) (PP mn AlmyAh) vs. (NP (QP Akvr mn 50 fy 100 mn) AlrjAl)
# give me a break:(NP (QP (NOUN *krY) (NUM 13)) (NOUN_PROP nysAn))!!
    while($line=~s/(\(NP\S*) \(QP((\s+\d+)+)\)((\s+\d+)*)( \((NP\S*|ADJP\S*)((\s+\d+)*)\))?\)/XXX-QP-XXX/){
	my $oldtag=$1;
	my $oldstr= "$2 $4";
	my $oldXP="$6";
	$oldXP=~s/ /\#/g;
	$oldstr.=" $oldXP";
	$oldstr=~s/^\s+//;
	$oldstr=~s/\s+$//;
	$oldstr=~s/\s+/ /g;

	my @oldstr=split('\s+',$oldstr);
	
	$oldstr=~s/(\S+)/\(NP $1X\)/g; 
	while($oldstr=~s/X\)(.*)/$1\)/){} 
	$oldstr="$oldtag $oldstr )";
	$oldstr=~s/\(NP (\S+) \)/$1/;
	$oldstr=~s/\(NP //;
	$oldstr=~s/\) //;
	$oldstr=~s/\#/ /g;
	$oldstr=~s/^\s+//;
	$oldstr=~s/\s+$//;
	$oldstr=~s/\s+/ /g;
	
	$line=~s/XXX-QP-XXX/$oldstr/;
    }

 
#if can't match above simple (but very common forms)... do this as worse cases scenario.. this causes high attachment

    while($line=~s/\(QP((\s+\d+)+)\)((\s+\d+)*)/XXX-QP-XXX/){
	my $oldstr= "$1 $3";
	$oldstr=~s/^\s+//;
	$oldstr=~s/\s+$//;
	$oldstr=~s/\s+/ /g;

	my @oldstr=split('\s+',$oldstr);
	
	$oldstr=~s/(\S+)/\(NP $1X\)/g; 
	while($oldstr=~s/X\)(.*)/$1\)/){} 
	$oldstr=~s/\(NP (\S+) \)/$1/;
	$oldstr=~s/\(NP //;
	$oldstr=~s/\)//;
	$oldstr=~s/^\s+//;
	$oldstr=~s/\s+$//;
	$oldstr=~s/\s+/ /g;
	
	$line=~s/XXX-QP-XXX/$oldstr/;
    }

#    if ($line=~/QP/){	
#	print "### $line\n";
#    }
    }


=cut



=pod
    }elsif ((${$MAP{"PARAM"}}{"CATiB"})&&($XP eq "NP")){
	# first non DT DEm , " . -LRB- -RRB- is initial head; 

	# DT DEm , " . -LRB- -RRB- are children of initial head and can not be parents

	# CC is child of initial head; but is mother of what follows it

	# PP,ADJP (XP) is child of ihead and canot be parents
	
	# POS tags -- are in right childhood lean

	#at end; @elements is empty

	my $ihead=0;
	for (my $i=0; $i<@ELEMENT;$i++){
	    if ($nodetag[$ELEMENT[$i]]!~/^(NONE|DT|DEM|\.|\,|\-LRB\-|\-RRB\-|\"|PUNC)$/){
		$ihead=$i; last;
	    }
	}
	$head=$ihead;
	for (my $i=0; $i<@ELEMENT;$i++){
	    if ($i!=$ihead){
		if ($nodetag[$ELEMENT[$i]]=~/^(NONE|DT|DEM|\.|\,|\-LRB\-|\-RRB\-|\"|PUNC|PP|ADJP|ADVP|SBAR|S)$/){
		    $parentnum[$ELEMENT[$i]]=$ELEMENT[$ihead];
		    $relation[$ELEMENT[$i]].="-MOD";
		    $head=$ihead;
		}elsif ($nodetag[$ELEMENT[$i]]=~/^NP$/){

		    if ($nodetag[$ELEMENT[$head]]=~/^CC$/){
			$parentnum[$ELEMENT[$i]]=$ELEMENT[$head];
			$relation[$ELEMENT[$i]].="-CONJ";
		    }else{
			$parentnum[$ELEMENT[$i]]=$ELEMENT[$ihead];
		    }
		    
		    if (($nodetag[$parentnum[$ELEMENT[$i]]] eq "NP")&&($nodetag[$ELEMENT[$i]] eq "NP")){
			if ($relation[$ELEMENT[$i]] eq "*"){
			    $relation[$ELEMENT[$i]].="-BADAL";
			}
		    }
		    if ($relation[$ELEMENT[$i]] eq "*"){
			if ($features[$ELEMENT[$ihead]]!~/ mudaf /){
			    $relation[$ELEMENT[$i]].="-IDAFA";
			    $features[$ELEMENT[$ihead]].=" mudaf ";
			}
		    }
		    
		    if ($nodetag[$ELEMENT[$head]]=~/^CC$/){
			$head=$i;
		    }else{
			$head=$ihead;
		    }

		}elsif($nodetag[$ELEMENT[$i]]=~/^(CC)$/){
		   # $parentnum[$ELEMENT[$i]]=$ELEMENT[$ihead];
		    $parentnum[$ELEMENT[$i]]=$ELEMENT[$head];
		    $relation[$ELEMENT[$i]].="-CC";
		    $head=$i;
		}else{
		    $parentnum[$ELEMENT[$i]]=$ELEMENT[$head];

		    if (($pos[$ELEMENT[$head]]eq "CC")){
			$relation[$ELEMENT[$i]].="-CONJ";
		    }
		    
		    if (($pos[$ELEMENT[$head]]eq "IN")&&($pos[$ELEMENT[$i]]=~/(NN|CD|WP)/)&&($head<$i)){
			$relation[$ELEMENT[$i]].="-POBJ";
			if (${$MAP{"PARAM"}}{"debug"}){print "$relation[$ELEMENT[$head]]\n";}
		    }
		    #if(($pos[$ELEMENT[$head]]=~/(NN|NNS|NOUN\_QUANT|JJ|RP)/)&&($pos[$ELEMENT[$i]]=~/(NN|NNS|NOUN\_QUANT|CD|PRP\$)/)){
		    if(($pos[$ELEMENT[$head]]=~/(NN|NNS|NOUN\_QUANT|JJ|RP)/)&&($pos[$ELEMENT[$i]]=~/(PRP\$)/)){
			if ($features[$ELEMENT[$head]]!~/ mudaf /i){
			    $features[$ELEMENT[$head]].=" mudaf ";
			    $relation[$ELEMENT[$i]].="-IDAFA";
			}
			if (${$MAP{"PARAM"}}{"debug"}){print "$relation[$ELEMENT[$head]]\n";}
		    }
		    

		    if ($pos[$ELEMENT[$head]]=~/PRP\$/){
			$parentnum[$ELEMENT[$i]]=$parentnum[$ELEMENT[$head]];
		    }
		    
		    if ($relation[$ELEMENT[$i]] eq "*"){
			$relation[$ELEMENT[$i]].="-MOD";
		    }
		    
		    if (($pos[$ELEMENT[$i]]=~/(NNP|NNPS)/)&&($i>1)&&($pos[$ELEMENT[$i-1]]=~/(NNP|NNPS)/)){
			$parentnum[$ELEMENT[$i]]=$ELEMENT[$i-1];
			$relation[$ELEMENT[$i]]="---";
		    }

		    ##NN JJ ==>  NN < JJ
		    if (($pos[$ELEMENT[$i]]=~/(JJ)/)&&($i>1)&&($pos[$ELEMENT[$i-1]]=~/(NN)/)){
			$parentnum[$ELEMENT[$i]]=$ELEMENT[$i-1];
			$relation[$ELEMENT[$i]]="-MOD";
		    }
		    

		    #$head=$i;
		}
	    }
	    if (${$MAP{"PARAM"}}{"debug"}){ print "$ELEMENT[$i] -> $parentnum[$ELEMENT[$i]]\n";}
	}
	@ELEMENT=($ELEMENT[$ihead]);
	$head=0;
	
=cut



=pod

	for (my $i=0;$i<@ELEMENT;$i++){
	    
	    if ($i != $head){
		
		if (${$MAP{"PARAM"}}{"debug"}){ print "inMAP: $pos[$ELEMENT[$head]] $nodetag[$ELEMENT[$i]] $relation[$ELEMENT[$i]]\n";}
#	    if (($pos[$head]=~/nHw/)&& ($pos[$ELEMENT[$head+1]]eq "CD")&&($i>$head+1)){		
#		$head=$i+1;
#	    }
		$parentnum[$ELEMENT[$i]]=$ELEMENT[$head];
		
		
		
		
		if (($pos[$ELEMENT[$i]]eq "CC")&& ($head<$i)){
		    $relation[$ELEMENT[$i]].="-CC";
		    $head=$i;
		next;
		}
		
		
		
		if (($pos[$ELEMENT[$head]]eq "CC")){
		    $relation[$ELEMENT[$i]].="-CONJ";
		}
		
		if (($pos[$ELEMENT[$head]]eq "IN")&&($nodetag[$ELEMENT[$i]] eq "NP")&&($head<$i)){
		    $relation[$ELEMENT[$i]].="-POBJ";
		    if (${$MAP{"PARAM"}}{"debug"}){print "$relation[$ELEMENT[$head]]\n";}
		}
		
		if(($pos[$ELEMENT[$head]]=~/^(AN)$/)&&($nodetag[$ELEMENT[$i]]=~/^(S)$/)){
		    $relation[$ELEMENT[$i]].="-OBJ";
		}
		
		if($nodetag[$ELEMENT[$i]]=~/(WHADVP)/){
		    $relation[$ELEMENT[$i]].="-MOD";
		}
		
		
		if(($pos[$ELEMENT[$head]]=~/^(RP)$/)&&($nodetag[$ELEMENT[$i]]=~/JJ/)){
		    if ($features[$ELEMENT[$head]]!~/ mudaf /){
			$features[$ELEMENT[$head]].=" mudaf ";
			$relation[$ELEMENT[$i]].="-IDAFA";
		    }
		    if (${$MAP{"PARAM"}}{"debug"}){print "$relation[$ELEMENT[$head]]\n";}
		}
		
		if(($pos[$ELEMENT[$head]]=~/^(NN|NNS|NOUN\_QUANT|JJ)$/)&&($nodetag[$ELEMENT[$i]] eq "NP")&&($relation[$ELEMENT[$i]] eq "*")){
		    if ($features[$ELEMENT[$head]]!~/ mudaf /){
			$features[$ELEMENT[$head]].=" mudaf ";
			$relation[$ELEMENT[$i]].="-IDAFA";
		    }
		    if (${$MAP{"PARAM"}}{"debug"}){print "$relation[$ELEMENT[$head]]\n";}
		}
		
		if ($relation[$ELEMENT[$i]] eq "*"){
		    $relation[$ELEMENT[$i]].="-MOD";
		}
		
		if (${$MAP{"PARAM"}}{"debug"}){ print "MAP: $pos[$ELEMENT[$head]] $nodetag[$ELEMENT[$i]] $relation[$ELEMENT[$i]]\n";}
		
	    }
	  }
    
    

    

#MORE TO CLEAN (all kinds of particles... ) from QP idafa mess.
    
    #Mark tamyyz; clean up;
    
    for (my $n=1; $n<=$maxnum;$n++){
	
	if ($features[$n]=~/DASHTAG:(\S+)/){
	    $relation[$n]=$1;
	}
	
	#print "$n $relation[$n] $pos[$parentnum[$n]] $pos[$n] $nodetag[$n] $features[$n]\n";
	
	if (($relation[$n] =~/(IDAFA)/)&& ($features[$n]=~/ACC/)){
	    $relation[$n]=~s/(IDAFA)/TMZ/;
	    $features[$parentnum[$n]]=~s/mudaf/mumayyaz/;
	}

	if (($relation[$n] =~/(IDAFA|MOD)/)&& ($pos[$parentnum[$n]] eq "CD") && ($pos[$n]=~/(NN|JJ|CD)/) && ($pos[$n]!~/(NNP)/) ){
	    
	    my $label=&NUMCLASS($inst[$parentnum[$n]]);
#	print "check $inst[$parentnum[$n]] = $label \n";

	    if (($features[$parentnum[$n]] !~/ mudaf /)&&($label eq "IDAFA")){
		$features[$parentnum[$n]].=" mudaf ";
		$relation[$n]=~s/MOD/IDAFA/;
	    }elsif (($features[$parentnum[$n]] !~/ mumayyaz /)&&($label eq "TMZ")){
		$relation[$n]=~s/(IDAFA|MOD)/TMZ/;
		$features[$parentnum[$n]].=" mumayyaz ";
	    }
	}elsif (($relation[$n] =~/(IDAFA)/)&&($pos[$n]=~/(CC)/) ){
	    $relation[$n] ="MOD";
	}elsif (($relation[$n] =~/(IDAFA|MOD)/)&& ($pos[$parentnum[$n]]=~/NN/) && ($pos[$n]!~/(NNP)/) ){
	    if (($pos[$n]=~/(NN|CD)/)&& ($pos[$n]!~/(NNP)/)){ #NOT JJ
		$relation[$n] ="IDAFA";
	    }elsif ($pos[$n]=~/(JJ)/){
		$relation[$n] ="MOD";
	    }
	}
      }
    
    
    #clean up IN that is in QP: in Akvr mn X; X is obj to mn and mn is mod to Akvr
    for (my $n=1; $n<=$maxnum;$n++){
	
	if ($features[$n]=~/DASHTAG:(\S+)/){
	    $relation[$n]=$1;
	}
        
	if (($relation[$n] =~/(IDAFA)/)&& ($pos[$parentnum[$n]] eq "IN")){
	    $relation[$n]=~s/(IDAFA)/POBJ/;
	}
	
	
	if (($relation[$n] =~/(IDAFA)/)&&($pos[$n]=~/(IN)/) ){
	    $relation[$n]=~s/(IDAFA)/MOD/;
	}
    }
    
    
    
    for (my $n=1; $n<=$maxnum;$n++){
	if (($relation[$n] =~/(SBJ|DTV)/) && ($pos[$n] ne "NONE")&& ($pos[$parentnum[$n]] eq "DV")){
	   # print "HELLLLOOOO $n $features[$parentnum[$n]]\n";
	    if ($features[$parentnum[$n]] !~/ mudaf /){
		print "HELLLLOOOO $n 22\n";
		$relation[$n].="-IDAFA";
		$features[$parentnum[$n]].=" mudaf ";
	    }
	}
    }
=cut
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;; Constituency to Depedency Mapper
#;; Copyright (c) 2010 Columbia University. All Rights Resereved.
#;; By Nizar Habash (habash@ccls.columbia.edu)  
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
