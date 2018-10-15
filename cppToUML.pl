#!/usr/bin/perl

use v5;
use strict;
use warnings;

use StoreClass;

my @classes = ();
my @openClasses = ();

# Reocurring regex patterns below
my $rCVOrStatic       = qr/(?>const|volatile|static)?(?>\h?volatile)?/;
my $rMatchXNamespaces = qr/(?>\w+::)*/;
my $rTemplateSpecialization = qr/(?>\w+<\w+>)/;

# Regexes used to identify:
# Class/struct definition
# Class/struct closure
# template class/struct definition
# Constructor or Destructor
# Member function
# Member variable
# template member function
my $rAccessModifier  = qr/(public|private|protected):/;
my $rConOrDestructor = qr/^((?>virtual\h?)?[\w~]+\(.*\)(?>\h?=\h?default|delete)?)/;
my $rMemberFunction  = qr/((?>virtual)?$rCVOrStatic\h?$rMatchXNamespaces(?>$rTemplateSpecialization|\w+)[\*\&]*\h?(\w+)(\(.*\)))(?>\h*=\h*0|\h*override\h*)?;/;
my $rMemberVariable  = qr/($rCVOrStatic\h?$rMatchXNamespaces(?>$rTemplateSpecialization|\w+)[ \*\&]+[\w\[\]]+);/;
my $rParent          = qr/(public|private|protected)\h?($rMatchXNamespaces[\w<>]+)/;
my $rIsTemplate      = qr/^(template\h?<.*>)/;
my $rClass           = qr/(class|struct)\h?(\w+)\h?:?$rMatchXNamespaces[\w\h,<>]+{/;
my $rClassClose      = qr/};$/;

# Matches template parameters
my $rTemplateParameters = qr/\w+\h?([\w\.]+[,>])/;

# Matches lines that contain namespace definitions or
# start with a comment or preprocessor directive
my $rSkipIf          = qr/^\h*(?:$|\/\/|#|namespace)/;
# Matching opening/closing multi line comments
my $rOpenMLComment = qr/(?:^\h*\/\*).*(?<!\*\/)/;
my $rCloseMLComment = qr/\*\//;

# When this matches, the string contains information
# That should most likely be placed in the UML
my $rTokenizeString  = qr/(?:{}?|;|$rAccessModifier)$/;

# Keep track when a multiline comment is being parsed
my $multiLineComment = 0;

# line gets appended until it matches with $rTokenizeString
my $line = "";

while(<>)
{
  # Remove '\n' from $_
  chomp;

  # If a comment spanning multiple lines begin on this line
  if($_ =~ /$rOpenMLComment/) {  $multiLineComment = 1; next; }

  # Skip if new line is empty or starts with a comment
  next if $_ =~ /$rSkipIf/;

  # If a multiline comment is currently being parsed
  if($multiLineComment)
  {
    # Check if it is closed on this line
    if($_ =~ /$rCloseMLComment/) { $multiLineComment = 0; }
    # Skip to next line regardless if the comment ended or not
    next;
  }
  
  # Append line until regex matches
  if($_ !~ /$rTokenizeString/)
  {
    $line .= " $_";
    next;
  }
  
  # This line will most likely result in an UML entry as the if statement
  # above matched. $_ is appended to $line which may or may not be empty
  $line .= " $_";
  
  # Replace multiple whitespaces with one
  $line =~ s/\h\h+/ /g;
  # Trim initial or trailing whitespace as well
  $line =~ s/^\h+|\h+$//g;

  if($line =~ /$rClass/)
  {
    # Create class
    my $class = new StoreClass($2);
    # class or struct will give different results
    $class->changeAccessModifier($1);
    # If it is a template class/struct
    if($line =~ /$rIsTemplate\h?$1/)
    {
      my $templateExpression  = $1;
      
      # Collect template parameters in array
      my @params = ();
      while($templateExpression =~ /$rTemplateParameters/g)
      {
        my $parameter;
        ($parameter = $1) =~ s/,|>//g;
        push @params, $parameter;
      }
      # Add all parameters to class
      $class->addClassTemplateParameters(@params);
    }
    
    # If inheritance is captured
    while($line =~ /$rParent/g)
    {
      $class->addParent($1,$2);
    }
     
    # Add to currently open classes
    push @openClasses, $class;
     
    $line = "";
    next;
  }

  # Only continue with recently closed line if it can be added to a class/struct
  unless(@openClasses) { $line = ""; next; }
  
  if($line =~ /$rClassClose/)
  {
    $line = "";
    push @classes, pop @openClasses;
    next;
  }
  
  # If member function or member variable, add to current class
  my $class = $openClasses[-1];

  # Add/modify the following for the currently parsed class if they match:
  # 1. Template member function
  # 2. Access modifier
  # 3. Constructor/Destructor
  # 4. Member function
  # 5. Member variable
  if($line =~ /$rIsTemplate\h?$rMemberFunction/) 
  { 
    my $templateExpression = $1;
    my $function = $3;
    my $parentheses = $4;
    
    $function .= "<";
    while($templateExpression =~ /$rTemplateParameters/g) 
    {
      $function .= $1;
    }
    $class->addMemberFunction("$function$parentheses");
  }
  elsif($line =~ /$rAccessModifier/)   { $class->changeAccessModifier($1); }
  elsif($line =~ /$rConOrDestructor/)  { $class->addMemberFunction($1);    }
  elsif($line =~ /$rMemberFunction/)   { $class->addMemberFunction($1);    }
  elsif($line =~ /$rMemberVariable/)   { $class->addMemberVariable($1);    }
  
  # Clear line
  $line = "";
}

print "\@startuml\n";
foreach my $class(@classes)
{
  bless $class, "StoreClass";
  $class->dump();
}
print "\@enduml\n";

