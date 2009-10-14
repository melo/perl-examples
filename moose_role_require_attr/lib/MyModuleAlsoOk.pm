package MyModuleAlsoOk;

use Moose;

with 'MyModule::ProvideAttr';
with 'MyModule::RequireAttr';

no Moose;

1;
