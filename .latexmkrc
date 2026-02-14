# Set input path so sub_1 files are found
$ENV{'TEXINPUTS'} = './sub_1//:' . ($ENV{'TEXINPUTS'} || '');

# Specify the main files
@default_files = ('sub_1/paper.tex','sub_1/paper_blind.tex','sub_1/sub_graphical_abstract.tex','sub_1/sub_highlights.tex','sub_1/sub_paper.tex','sub_1/sub_paper_blind.tex');

$pdflatex = 'pdflatex -aux-directory=tmp %O -interaction=nonstopmode -shell-escape %S';

# Specify the bibliography
$bibtex = 'bibtex %O %B';
$makeglossaries = 'makeglossaries %O %B';

# Continuous preview mode
$continuous_mode = 1;

# Output to PDF
$pdf_mode = 1;

# Auxiliary files
$aux_dir = 'tmp';

# Keep auxiliary files
$clean_ext = "";

add_cus_dep( 'acn', 'acr', 0, 'makeglossaries' );
add_cus_dep( 'glo', 'gls', 0, 'makeglossaries' );
$clean_ext .= " acr acn alg glo gls glg";

sub makeglossaries {
	my ($base_name, $path) = fileparse( $_[0] );
	my @args = ( "-q", "-d", $path, $base_name );
	if ($silent) { unshift @args, "-q"; }
	return system "makeglossaries", "-d", $path, $base_name; 
}


# Silence warnings
$silent = 1;



