package Auth::Controller::Auth;

use parent qw/Catalyst::Controller/;

sub login : Local {
  my ($self, $c) = @_;
  
  my $user     = $c->req->params->{user};
  my $password = $c->req->params->{password};
  my $auth_ok;
  
  if ($user && $password) {
    $auth_ok = $c->authenticate(
      { username => $user,
        password => $password,
      }
    ) || 0;

    if ($auth_ok) {
      $c->res->body("hello " . $c->user->get("name"));
      $c->detach;
    }
  }

  my $body = "<h1>How do you say you are??</h1>";
  use Data::Dumper; print STDERR ">>>>>> ", Dumper($auth_ok);
  
  $body .= '<p style="color: red">These are not the droids you are looking for...</p>'
    if defined($auth_ok) && !$auth_ok;
  $body .= <<"  EOF";
    <form>
      <label for="user">User:</label><input id="user" name="user"><br />
      <label for="password">Password:</label><input id="password" name="password" type="password"><br />
      <input type="submit" name="btn_login" value="Login">
    </form>
  EOF
  $c->res->body($body);
}

1;
