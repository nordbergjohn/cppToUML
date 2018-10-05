#!/usr/bin/perl
#StoreClass.pm, Storing class information
use strict;
use warnings;

package StoreClass;

sub translateAccessModifierToPlantUML
{
  my $modifier = shift;
  my $retVal = '';

  # Change retVal to private/protected or public plantUML token
  if    ($modifier =~ /class|private/)  { $retVal = '-'; }
  elsif ($modifier =~ /protected/)      { $retVal = '#'; }
  elsif ($modifier =~ /struct|public/)  { $retVal = '+'; }
}

sub new
{
  my $class = shift;

  # Init class or struct
  my $self = { name => shift };

  # class or struct give private or public access modifier
  $self->{accessModifier} = translateAccessModifierToPlantUML($self->{name});

  # Replace struct with class for plantuml compatibility
  $self->{name} =~ s/struct/class/g;
  
  # Init empty member lists
  $self->{parents}         = ();
  $self->{memberFunctions} = ();
  $self->{memberVariables} = ();

  bless $self, $class;
}

# Currently, it does not care about the access modifier of the parent
sub addParent
{
  my $self            = shift;
  my $inheritanceType = shift; # public/private/protected, not used atm
  my $parentName      = shift;
  push @{$self->{parents}}, $parentName;
}

sub addMemberFunction {
  my   $self = shift;
  my   $fun  = shift;

  push @{$self->{memberFunctions}}, "$self->{accessModifier} $fun";
}

sub addMemberVariable {
  my   $self = shift;
  my   $var  = shift;

  push @{$self->{memberVariables}}, "$self->{accessModifier} $var";
}

sub changeAccessModifier {
  my $self = shift;

  $self->{accessModifier} = translateAccessModifierToPlantUML(shift);
}

sub dump {
  my $self = shift;
  my $className = @{[$self->{name} =~ m/\w+/g]}[1];

  # Class opening line
  print"$self->{name} {\n";

  # Fill class with member functions and variables
  foreach my $func (@{$self->{memberFunctions}})
  {
    print("$func\n");
  }
  foreach my $var (@{$self->{memberVariables}})
  {
    print("$var\n");
  }

  # Class closing line
  print "}\n";

  # Handle inheritance
  foreach my $parent (@{$self->{parents}})
  {
    print("$parent <|-- $className\n");
  }
}

1; # To return a true value
