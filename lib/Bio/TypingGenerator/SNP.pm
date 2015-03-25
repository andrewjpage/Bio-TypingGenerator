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
	my @clusters = uniq sort values %{$self->variation_samples_to_clusters};
	return \@clusters;
}

sub _build_reference_clusters
{
	my($self) = @_;
	my @clusters = uniq sort values %{$self->reference_samples_to_clusters};
	return \@clusters;
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
			$variation_samples_to_clusters{$self->columns_to_samples->[$i-9]} = $self->samples_to_clusters->{$self->columns_to_samples->[$i-9]};
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
			$variation_samples_to_clusters{$self->columns_to_samples->[$i-9]} = $self->samples_to_clusters->{$self->columns_to_samples->[$i-9]};
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