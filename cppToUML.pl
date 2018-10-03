#!/usr/bin/perl

use Getopt::Long;

# Needed on mac to find StoreClass.pm
use lib '.';
use StoreClass;

my $help = '';
GetOptions('h' => \$help, 'help' => \$help);

sub printUsage {
  print "Usage: ./generateUML <comma separated list of files containing C++ classes>\n\n";  

  print "Available flags:\n";
  print "\t-h,-help\tPrint help\n\n";
}

sub printExample {
  print "Example usage:\t./.generateUML /path/to/header/file1 /path/to/header/file2\n";
  print "Output: \@plantuml output of given input files to stdout\n\n";
  print "\@startuml\nParentClass <|-- File1\nclass File1 {\n+void publicMember()\n#int protectedVar;\n}\n\n";
  print "ParentClass2 <|-- File2\nclass File2 {\n-void privateMember()\n}\n\@enduml\n";
}

if($help)
{
  printUsage();
  printExample();
  exit;
}

if($#ARGV == -1)
{
  print "Error! Expecting file input\n\n";
  printUsage();
  exit;
}

my @classes = ();

# Iterate over argv
foreach(@ARGV)
{
  my @openClasses = ();
  if(open(FILE, $_))
  { 
    my $parsingInheritance = 0;
    foreach (<FILE>)
    {
      # Skip if new line is empty or starts with a comment
      next if $_ =~ /^\h*(?:$|\/\/)/;

      # When done with a class, go to next line
      if(@openClasses and $_ =~ /^};$/)
      {
        push @classes, pop @openClasses;
        next;
      }

      # If no class is being parsed and a class is found
      if($_ =~ /^\h*(class|struct)\h+(\w+)/)
      {
        my $class = new StoreClass("$1 $2");
        push @openClasses, $class;

        if(index($_,":") != -1)
        {
          $parsingInheritance = 1;
          while($_ =~ /(public|private|protected)\h+((?:\w+::)*\w+)/g)
          {
            $class->addParent($1,$2);
          }
        }

        # If class opening braces are on the same line as the parent classes
        if(index($_,'{') != -1)
        {
          $parsingInheritance = 0;
          next;
        }
      }

      if(@openClasses)
      {
        my $class = $openClasses[-1];

        # Check if currently parsing inheritance
        if($parsingInheritance)
        {
          my $class = $openClasses[-1];
          while($_ =~ /(public|private|protected)\h+((?:\w+::)*\w+)/g)
          {
            $class->addParent($1,$2);
          }

          # Parent class definitions done
          if($_ =~ /{/)
          {
            $parsingInheritance = 0;
            next;
          }
        }

        if($_ =~ /^\h*(public|private|protected):/)
        {
          $class->changeAccessModifier($1);
        }
        elsif($_ =~ /(\w+ \w+\(.*\))/)
        {
          $class->addMemberFunction($1);
        }
        elsif($_ =~ /(\w+ \w+);/)
        {
          $class->addMemberVariable($1);
        }
      }
    }
    close(FILE);
  }
  else
  {
    print "Could not open file '$_' $!\n";
  }
}

print "\@startuml\n";
foreach $class(@classes)
{
  bless $class, "StoreClass";
  $class->dump();
}
print "\@enduml\n";

