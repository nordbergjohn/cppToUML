#!/usr/bin/perl
#StoreClass.pm, Storing class information

use v5;
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

  my $self = { name => shift };
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

sub addClassTemplateParameters {
  my ($self, @params) = @_;

  # As this becomes a template class, it will use a handle for UML inheritance
  # e.g., template<class T, typename Args...> class Example will become
  # 'class "Example<T, Args...>" as Example_T_Args' in plantuml
  my $additionalText = "as ";
  $additionalText .= $self->{name};

  # Create template class string
  $self->{name} .= "<";
  foreach (@params) 
  {
    $self->{name} .= "$_, ";
    $additionalText .= "_$_";
  }
  
  # Last ', ' should be closing >
  $self->{name} =~ s/,\h$/>/g;
  # Remove variadic dots from class name used for inheritance
  $additionalText =~ s/\.//g;
  $self->{name} = "\"" . $self->{name} . "\" $additionalText";
}

sub addMemberFunction {
  my   $self = shift;
  
  push @{$self->{memberFunctions}}, $self->{accessModifier} . shift;
}

sub addMemberVariable {
  my   $self = shift;

  push @{$self->{memberVariables}}, $self->{accessModifier} . shift;
}

sub changeAccessModifier {
  my $self = shift;

  $self->{accessModifier} = translateAccessModifierToPlantUML(shift);
}

sub dump {
  my $self = shift;
  
  my $className = $self->{name};
  # If it is a template class, pick out 'alias'
  if($self->{name} =~/as (.*)/)
  {
    $className = $1;
  }

  # Class opening line
  print "class $self->{name} {\n";

  # Fill class with member functions and variables
  foreach my $func (@{$self->{memberFunctions}})
  {
    print "$func\n";
  }
  foreach my $var (@{$self->{memberVariables}})
  {
    print "$var\n";
  }

  # Class closing line
  print "}\n";

  # Handle inheritance
  foreach my $parent (@{$self->{parents}})
  {
    $parent =~ s/<|,/_/g;
    $parent =~ s/>//g;
    print "$parent <|-- $className\n";
  }
}

1; # To return a true value
