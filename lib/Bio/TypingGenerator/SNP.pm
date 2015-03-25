package Bio::TypingGenerator::SNP;

# ABSTRACT: Represents a single SNP

=head1 SYNOPSIS

Find defining snps

=cut

use Moose;
use Text::CSV;
use List::MoreUtils qw(uniq);

has 'vcf_line'               => ( is => 'ro', isa => 'Str', required => 1 );
has 'columns_to_samples'     => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'samples_to_clusters'    => ( is => 'rw', isa => 'HashRef',  required => 1 );

has 'coordinate'                       => ( is => 'rw', isa => 'Int',     lazy => 1, builder => '_build_coordinate' );
has 'variation_samples_to_clusters'    => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_variation_samples_to_clusters' );
has 'reference_samples_to_clusters'    => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_reference_samples_to_clusters' );
has 'variation_clusters'               => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => '_build_variation_clusters' );
has 'reference_clusters'               => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => '_build_reference_clusters' );

sub _build_variation_clusters
{
	my($self) = @_;
    my @values = values %{$self->variation_samples_to_clusters};
	return [] if(! @values || @values == 0 );
	my @clusters = uniq sort @values;
	return \@clusters;
}

sub _build_reference_clusters
{
	my($self) = @_;
	my @values = values %{$self->reference_samples_to_clusters};
	return [] if(! @values || @values == 0 );
	my @clusters = uniq sort @values;
	return \@clusters;
}

sub unique_cluster
{
  my($self) = @_;
  if(@{$self->variation_clusters} == 1)
  {
	  for my $comparison_cluster(@{$self->reference_clusters})
	  {
		  return undef if($comparison_cluster == $self->variation_clusters->[0]);
	  }
    return $self->variation_clusters->[0];
  }
  elsif(@{$self->reference_clusters} == 1)
  {
	  for my $comparison_cluster(@{$self->variation_clusters})
	  {
		  return undef if($comparison_cluster == $self->reference_clusters->[0]);
	  }
  	return $self->reference_clusters->[0];
  }
  else
  {
	  return undef;
  }  
}

sub _build_variation_samples_to_clusters
{
	my($self) = @_;
	my @row;
	my @cells = split(/\t/,$self->vcf_line);
	
	my %variation_samples_to_clusters;
	for(my $i =9; $i< @cells; $i++ )
	{
		unless($cells[$i] eq '.')
		{
			if(defined($self->samples_to_clusters->{$self->columns_to_samples->[$i-9]}))
			{
				$variation_samples_to_clusters{$self->columns_to_samples->[$i-9]} = $self->samples_to_clusters->{$self->columns_to_samples->[$i-9]};
			}
			else
			{
				print "Cant lookup ".$self->columns_to_samples->[$i-9]."\n";
			}
		}
	} 
	return \%variation_samples_to_clusters;
}

sub _build_reference_samples_to_clusters
{
	my($self) = @_;
	my @row;
	my @cells = split(/\t/,$self->vcf_line);
	
	my %variation_samples_to_clusters;
	for(my $i =9; $i< @cells; $i++ )
	{
		if($cells[$i] eq '.')
		{
			if(defined($self->samples_to_clusters->{$self->columns_to_samples->[$i-9]}))
			{
				$variation_samples_to_clusters{$self->columns_to_samples->[$i-9]} = $self->samples_to_clusters->{$self->columns_to_samples->[$i-9]};
			}
			else
			{
			    print "Cant lookup ".$self->columns_to_samples->[$i-9]."\n";
			}
		}
	} 
	return \%variation_samples_to_clusters;
}

sub _build_coordinate
{
	my($self) = @_;
	my @cells = split(/\t/,$self->vcf_line);
	return $cells[1];
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
