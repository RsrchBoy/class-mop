#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('Class::MOP');   
    use_ok('Class::MOP::Class');        
}

=pod

  A
 / \
B   C
 \ / 
  D

=cut

{
    package My::A;
    package My::B;
    our @ISA = ('My::A');
    package My::C;
    our @ISA = ('My::A');    
    package My::D;       
    our @ISA = ('My::B', 'My::C');         
}

is_deeply(
    [ Class::MOP::Class->initialize('My::D')->class_precedence_list ], 
    [ 'My::D', 'My::B', 'My::A', 'My::C', 'My::A' ], 
    '... My::D->meta->class_precedence_list == (D B A C A)');

=pod

 A <-+
 |   |
 B   |
 |   |
 C --+

=cut

{
    package My::2::A;
    our @ISA = ('My::2::C');
        
    package My::2::B;
    our @ISA = ('My::2::A');
    
    package My::2::C;
    our @ISA = ('My::2::B');           
}

eval { Class::MOP::Class->initialize('My::2::B')->class_precedence_list };
ok($@, '... recursive inheritance breaks correctly :)');

=pod

 +--------+
 |    A   |
 |   / \  |
 +->B   C-+
     \ / 
      D

=cut

{
    package My::3::A;
    package My::3::B;
    our @ISA = ('My::3::A');
    package My::3::C;
    our @ISA = ('My::3::A', 'My::3::B');    
    package My::3::D;       
    our @ISA = ('My::3::B', 'My::3::C');         
}

is_deeply(
    [ Class::MOP::Class->initialize('My::3::D')->class_precedence_list ], 
    [ 'My::3::D', 'My::3::B', 'My::3::A', 'My::3::C', 'My::3::A', 'My::3::B', 'My::3::A' ], 
    '... My::3::D->meta->class_precedence_list == (D B A C A B A)');