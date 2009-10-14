package MyModule;

use Moose;

## Order matters, place 'with' after 'has'

has attr => (
  isa => 'Str',
  is  => 'rw',
);

with 'MyModule::RequireAttr';

no Moose;

1;
