package MyModule::ProvideAttr;

use Moose::Role;

has attr => (
  isa => 'Str',
  is  => 'rw',
);

1;
