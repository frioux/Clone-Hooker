package Clone::Hooker;

use MooseX::Role::Parameterized;

parameter copy => (
   isa  => 'ArrayRef[Str]',
   default => sub { [] },
);

parameter reference => (
   isa  => 'ArrayRef[Str]',
   default => sub { [] },
);

role {
   my $p = shift;

   my @stack;

   my @copy      = @{$p->copy};
   my @reference = @{$p->reference};

   method STORABLE_freeze => sub {
      my ($self, $cloning) = @_;

      die q(you can't freeze this thing silly!) unless $cloning;

      my %frame;
      for my $ref (@reference) {
         $frame{$ref} = $self->$ref
      }
      push @stack, \%frame;

      my %ret;
      for my $cop (@copy) {
         $ret{$cop} = $self->$cop
      }

      return \%ret
   };

   method STORABLE_thaw => sub {
      my ($self, $cloning, $ice) = @_;

      die q(you can't thaw this thing silly!) unless $cloning;
      my %frame = %{pop @stack};
      my $new = $self->new({
         %$self,
         map {
            $_ => $frame{$_}
         } keys %frame,
      });

      %$self = %$new;
   }
};

no MooseX::Role::Parameterized;

1;

