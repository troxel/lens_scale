#!/usr/bin/perl

use Image::Magick;

# Toogle on the version/time footer.
$Foot_info_flg = 1;

# Include our friends
use WebFrame::Web;
use WebFrame::Sys;
use WebFrame::Save;
use WebFrame::TemplateRex;
use WebFrame::Debug;
use WebFrame::Tmp;

use WebFrame;

use JSON; 

%Conf = get_conf();
%Conf_src = %{$Conf{src}};

# Chip size (inch) 1/4"  1/3"  1/2"   2/3"    1"      1/2.8"
# long side (mm)   3.6   4.8   6.4    8.8    12.75    5.44
# short side (mm)  2.7   3.6   4.8    6.6     9.525   3.06
# diagonal (mm)    4.5   6.0   8.0   10.991  15.875

# ------------------------------------------
# CCD Devices Information 
# These have to match exactly the keys for the %Ccd hash below. This list controls the order shown in the pull down 
my @Ccd_lst = ('DSLR-FF', 'T25um-385', 'T17um-320', 'T17um-640', 'T15um-640', 'T10um-640', 'T12um-320', 'T12um-640', 'T15um-1280', 'T10um-1280','1/4', '1/3', '1/2.8', '1/2.5', '1/2', '1/1.8', '1/1.7', '2/3', '1');

# Particulars of devices. The lbl key is the label shown in the pull down. 
my %Ccd;
$Ccd{'1/4'}   = { 'lbl'=>'1/4"',  'x'=>3.6, 'y'=>2.7,  'ratio'=> 1.3333 };
$Ccd{'1/3'}   = { 'lbl'=>'1/3"',  'x'=>4.8, 'y'=>2.7,  'ratio'=> 1.7778 };
$Ccd{'1/2.8'} = { 'lbl'=>'1/2.8"','x'=>5.44,'y'=>3.06, 'ratio'=> 1.7778 };
$Ccd{'1/2.5'} = { 'lbl'=>'1/2.5"','x'=>5.76,'y'=>4.29, 'ratio'=> 1.3427 };
$Ccd{'1/2'}   = { 'lbl'=>'1/2"',  'x'=>6.4, 'y'=>4.8,  'ratio'=> 1.3333 };
$Ccd{'1/1.8'} = { 'lbl'=>'1/1.8"','x'=>7.18,'y'=>4.04, 'ratio'=> 1.7772 };
$Ccd{'1/1.7'} = { 'lbl'=>'1/1.7"','x'=>7.6, 'y'=>5.7,  'ratio'=> 1.3333 };
$Ccd{'2/3'}   = { 'lbl'=>'2/3"',  'x'=>8.8, 'y'=>6.6,  'ratio'=> 1.3333 };
$Ccd{'1'}     = { 'lbl'=>'1"',    'x'=>12.7,'y'=>9.525,'ratio'=> 1.3333 };
$Ccd{'DSLR-FF'}    = { 'lbl'=>'DSLR-FF',        'x'=>36,   'y'=>24,  'ratio'=> 1.5000 };
$Ccd{'T25um-385'}  = { 'lbl'=>'T25&#956;m-385', 'x'=>9.625,'y'=>7.15,'ratio'=> 1.3462 };
$Ccd{'T17um-320'}  = { 'lbl'=>'T17&#956;m-320', 'x'=>5.44, 'y'=>4.08,'ratio'=> 1.3333, 'x_px'=>320, 'y_px'=>240 };
$Ccd{'T17um-640'}  = { 'lbl'=>'T17&#956;m-640', 'x'=>10.88,'y'=>8.16,'ratio'=> 1.3333 ,'x_px'=>640 };
$Ccd{'T15um-640'}  = { 'lbl'=>'T15&#956;m-640', 'x'=>9.6,  'y'=>7.2, 'ratio'=> 1.3333, 'x_px'=>640 };
$Ccd{'T10um-640'}  = { 'lbl'=>'T10&#956;m-640', 'x'=>6.4,  'y'=>4.8, 'ratio'=> 1.3333, 'x_px'=>640 };
$Ccd{'T12um-320'}  = { 'lbl'=>'T12&#956;m-320', 'x'=>3.84, 'y'=>2.88,'ratio'=> 1.3333, 'x_px'=>320 };
$Ccd{'T12um-640'}  = { 'lbl'=>'T12&#956;m-640', 'x'=>7.68, 'y'=>5.76,'ratio'=> 1.3333, 'x_px'=>640 };
$Ccd{'T15um-1280'} = { 'lbl'=>'T15&#956;m-1280','x'=>19.2, 'y'=>10.8,'ratio'=> 1.7778, 'x_px'=>1280 };
$Ccd{'T10um-1280'} = { 'lbl'=>'T10&#956;m-1280','x'=>12.8, 'y'=>7.2, 'ratio'=> 1.7778, 'x_px'=>1280 };
 
# Create label hash for pull down... 
my %Ccd_lbl = map { $_=>"$Ccd{$_}->{lbl}" } @Ccd_lst;

# ------------------------------------------
# Objective information. 
# Follows the same pattern as above. Elements of the lst need to be keys in the hash. 
my @Obj_lst = ('Human', 'SUV', 'AUV');
my %Obj;
$Obj{'Human'} = {'lbl'=>'Human [1.8m x 0.5m]','y'=>2};
$Obj{'SUV'}   = {'lbl'=>'SUV [2.3m x 2.3m]',  'y'=>1.8}; 
$Obj{'AUV'}   = {'lbl'=>'AUV [0.4m x 0.2m]',  'y'=>.5};
				
# Create label hash for pull down... 
my %Obj_lbl = map { $_=>"$Obj{$_}->{lbl}" } @Obj_lst;

# ------------------------------------------
# Resolution information. 
# Follows the same pattern as above. Elements of the lst need to be keys in the hash. 
my @Resolution_lst = qw(VGA SVGA 720p 1.3MP 2MP 1080p 3MP 4MP 5MP 6MP 4K 10MP 12MP 16MP 6K 7K);    
my %Resolution;
$Resolution{'VGA'}   = {'x_px'=>640 , 'y_px'=>480 , 'lbl'=>'VGA   640 x 480'};  
$Resolution{'SVGA'}  = {'x_px'=>800 , 'y_px'=>600 , 'lbl'=>'SVGA  800 x 600'};  
$Resolution{'720p'}  = {'x_px'=>1280, 'y_px'=>720 , 'lbl'=>'720p  1280 x 720'}; 
$Resolution{'1.3MP'} = {'x_px'=>1280, 'y_px'=>1024, 'lbl'=>'1.3MP 1280 x 1024'};
$Resolution{'2MP'}   = {'x_px'=>1600, 'y_px'=>1200, 'lbl'=>'2MP   1600 x 1200'};
$Resolution{'1080p'} = {'x_px'=>1920, 'y_px'=>1080, 'lbl'=>'1080p 1920 x 1080'};
$Resolution{'3MP'}   = {'x_px'=>2048, 'y_px'=>1536, 'lbl'=>'3MP   2048 x 1536'};
$Resolution{'4MP'}   = {'x_px'=>2688, 'y_px'=>1520, 'lbl'=>'4MP   2688 x 1520'};
$Resolution{'5MP'}   = {'x_px'=>2592, 'y_px'=>1944, 'lbl'=>'5MP   2592 x 1944'};
$Resolution{'6MP'}   = {'x_px'=>3072, 'y_px'=>2048, 'lbl'=>'6MP   3072 x 2048'};
$Resolution{'4K'}    = {'x_px'=>3840, 'y_px'=>2160, 'lbl'=>'4K    3840 x 2160'};
$Resolution{'10MP'}  = {'x_px'=>3648, 'y_px'=>2752, 'lbl'=>'10MP  3648 x 2752'};
$Resolution{'12MP'}  = {'x_px'=>4000, 'y_px'=>3000, 'lbl'=>'12MP  4000 x 3000'};
$Resolution{'16MP'}  = {'x_px'=>4608, 'y_px'=>3456, 'lbl'=>'16MP  4608 x 3456'};
$Resolution{'6K'}    = {'x_px'=>6016, 'y_px'=>4008, 'lbl'=>'6K    6016 x 4008'};
$Resolution{'7K'}    = {'x_px'=>7360, 'y_px'=>4128, 'lbl'=>'7K    7360 x 4128'};
                                      
# Create label hash for pull down... 
my %Resolution_lbl = map { $_=>"$Resolution{$_}->{lbl}" } @Resolution_lst;

# Used in javascript... 
$Data{json_ccd} = encode_json \%Ccd;
$Data{json_obj} = encode_json \%Obj;
$Data{json_res} = encode_json \%Resolution;

my @K_lst = qw/lens_mm size dist_z fov_x fov_y degree/;

$Ssn{'units'} = $Query{'units'} || 'Metric';

if ( $Ssn{'units'} eq 'Metric' )
{
  $Data{'unit_l'} = "(m)";
  $Data{'metric_ck'} = 'checked';
}
elsif ( $Ssn{'units'} eq 'Customary' )
{
  $Data{'unit_l'} = "(ft)";
  $Data{'customary_ck'} = 'checked';
  cust2metric(\%Query);
}

@Clr = ( '#A8C7F0', '#BADCE8' );

WebFrame::TemplateRex->set_defaults({'inc_dir_lst'=>[ "$Dir{src}/templates", "./templates" ],'sub_dir'=>"" });
$trx_layout = new WebFrame::TemplateRex({'file'=>'t-layout.html'});

my $rtn = &do_callback();
exit;

# - - - - - - - - - - - - - - - - - - - -
sub cb_default
{
  my $trx = new WebFrame::TemplateRex( { file=>"t-default.html"} );
  $Data{'time'} = localtime(time);

  # ---- Validate ----
  $Query{'lens_mm'} =~ s/\D//g;
  unless ( $Query{'lens_mm'} ) { $Query{'lens_mm'} = 50; }
  unless ( $Query{'obj'} ) { $Query{'obj'} = 'Human'; }
    
  $Query{'degree'} = 2 * atan2( $Query{'fov_x'}/2, $Query{'dist_z'} ) * 57.2957795;

  if ( $Ssn{'units'} eq 'Customary' ) { metric2cust(\%Query)}

  toFixed(\%Query);

  $trx->render_sec('data_row',\%Query);

  if ( $Ssn{'units'} eq 'Customary' ) { metric2cust(\%Query); }
  toFixed(\%Query);

  $Query->{'escape'} = 0;
  $Data{'popup_ccd'} = $Query->popup_menu(-name=>'size',-values=>\@Ccd_lst,-labels=>\%Ccd_lbl,-default=>[$Query{'size'}],-id=>"ccd_select");
  $Data{'popup_obj'} = $Query->popup_menu(-name=>'obj',-values=>\@Obj_lst,-labels=>\%Obj_lbl,-default=>[$Query{'obj'}],-id=>"obj_select");
  $Data{'popup_res'} = $Query->popup_menu(-name=>'res',-values=>\@Resolution_lst,-labels=>\%Resolution_lbl,-default=>[$Query{'res'}],-id=>"res_select");

  if ($Query{fov_y} )
  {
    #$Data{fov_x_pix} = 750;
    #$Data{win_y_px} = 421;

    #$Data{target_y} = 2*421/$Query{fov_y};
  }
  
  ##$Data{'img_target'} = "$Url{src}/img/man_standing.jpg";
  $Data{'img_target'} = "$Url{src}/img/$Query{'obj'}.svg";

  $Data{'content'} = $trx->render( {%Query, %Data} );

  send_now( $trx_layout->render( \%Data ) );
  exit;
}


# - - - - - - - - - - - - - - - - - - - -
sub cb_scale
{

  my $trx = new WebFrame::TemplateRex( { file=>"t-default.html"} );
  $Data{'time'} = localtime(time);

  my @db_lst = @{$Ssn{db}};

  my $inx=0;
  foreach my $ref (reverse @db_lst)
  {
    my %hsh = %{$ref};
    $hsh{'inx'} = $inx++;

   $hsh{'degree'} = 2 * atan2( $hsh{'fov_x'}/2, $hsh{'dist_z'} ) * 57.2957795;

   if ( $Ssn{'units'} eq 'Customary' ) { metric2cust(\%hsh)}

    toFixed(\%hsh);

    $hsh{'row_clr'} = $Clr[$inx % 2];
    $trx->render_sec('data_row',\%hsh);
  }

  if ( $inx ) { $trx->render_sec('control_blk'); }

  if ( $Ssn{'units'} eq 'Customary' ) { metric2cust(\%Query); }
  toFixed(\%Query);

  $Data{'popup_ccd'} = $Query->popup_menu(-name=>'size',-values=>\@Ccd_lst,-labels=>\%Ccd_lbl,-default=>[$size]);

  $Data{'content'} = $trx->render( {%Query, %Data} );

  send_now( $trx_layout->render( \%Data ) );
  exit;
}

sub cb_scale_image
{
    my($image, $x);

    $image = Image::Magick->new;
    $x = $image->Read("$Dir{src}/man_standing.jpg");
    warn "$x" if "$x";

    #$x = $image->Crop(geometry=>'50x50"+1"00"+1"00');
    #warn "$x" if "$x";

    #$x = $image->Write("$Dir{src}/man_standing_mod.jpg");
    #warn "$x" if "$x";

    #$x = $image->Resize(100,100);
    #warn "$x" if "$x";

    $image->Resize(geometry => "300x100");
    $image->Resize(geometry => "320x320");

    print "Content-type: image/png\n\n";
    binmode STDOUT;
    $x = $image->Write('-');
    exit;

}


###############################################



# - - - - - - - - - - - - - - - - - - - - - - -
sub cb_calc_height
{

  my $ccd_ref = $Ccd{$Query{'size'}};
  $Query{'fov_x'} = ( $ccd_ref->{'x'}/$Query{'lens_mm'})  * $Query{'dist_z'};

  $Query{'fov_y'} = ( $ccd_ref->{'y'}/$Query{'lens_mm'})  * $Query{'dist_z'};

  cb_default();
}

# - - - - - - - - - - - - - - - - - - - - - - -
sub cb_calc_dist
{

  my $ccd_ref = $Ccd{$Query{'size'}};
  $Query{'dist_z'} = ( $Query{'fov_x'} / $ccd_ref->{'x'} ) * $Query{'lens_mm'};

  $Query{'fov_y'} = $Query{'fov_x'} * ($ccd_ref->{'y'}/$ccd_ref->{'x'}); # Meters

  cb_default();
}

# - - - - - - - - - - - - - - - - - - - - - - -
sub cb_calc_lens_mm
{
  my $ccd_ref = $Ccd{$Query{'size'}};

  $Query{'lens_mm'} = ( $Query{'dist_z'} /$Query{'fov_x'} ) * $ccd_ref->{'x'};

  $Query{'fov_y'} = $Query{'fov_x'} * ($ccd_ref->{'y'}/$ccd_ref->{'x'}); # Meters

  cb_default();
}

# - - - - - - - - - - - - - - - - - - - - - - -
sub cb_remove
{
  if ( defined $Query{'inx'}  )
  {
      my @lst = @{$Ssn{'db'}};

      my @lst_l = @lst[0..($Query{'inx'}-1)];
      my @lst_r = @lst[($Query{'inx'}+1)..$#lst];
      $Ssn{'db'} = [@lst_l, @lst_r];
  }
  else
  {
     $Ssn{'db'} = [];
  }

  cb_default();
}

# - - - - - - - - - - - - - - - - - - - - - - -
sub cb_email_lst
{
 require WebFrame::Email; WebFrame::Email->import(send_mail);

 my $trex = new WebFrame::TemplateRex( { file=>"t-email_lst.html",'cmnt_verbose'=>'0' } );

 unless ($Query{'email_to'} =~ /[\w\-]+\@[\w\-]+\.[\w\-]+/)
 {
   $Query{'email_err_msg'} = "$Query{'email_to'} is invalid";
   cb_default();
 }

 my %email_hsh;
 $email_hsh{'to'}   = $Query{'email_to'};

 $email_hsh{'from'} = $Conf_src{'email_from'};
 $email_hsh{'bcc'}  = $Conf_src{'email_cc'};

  my @db_lst = @{$Ssn{db}};

  my $inx=0;
  foreach my $ref (reverse @db_lst)
  {
    my %hsh = %{$ref};
    $hsh{'inx'} = $inx++;
    if ( $Ssn{'units'} eq 'Customary' ) { metric2cust(\%hsh); }

    toFixed(\%hsh);

    #$hsh{'row_clr'} = $Clr[$inx % 2];
    $trex->render_sec('data_row',\%hsh);
  }

  $email_hsh{'msg'} = $trex->render( {%Query, %Data} );
  $email_hsh{'subject'} = 'DVR Lens Calculations';

  send_mail(\%email_hsh);
  $Query{'email_err_msg'} = "Email Sent to $Query{'email_to'}";
  cb_default();
}

#--------------------------------
sub cust2metric
{
  my $ref = shift @_;
  @lst = qw( dist_z fov_x fov_y );
  foreach my $k ( @lst ) { $ref->{$k} = $ref->{$k}/3.2808399 ; }
  return $ref;
}

#--------------------------------
sub metric2cust
{
  my $ref = shift @_;

  @lst = qw( dist_z fov_x fov_y );
  foreach my $k ( @lst ) { $ref->{$k} = $ref->{$k} * 3.2808399; }

  return $ref;
}

#--------------------------------
sub toFixed
{
  my $ref = shift @_;
  @lst = qw( dist_z fov_x fov_y degree);
  foreach my $k ( @lst ) { if ( $ref->{$k} ) { $ref->{$k} = sprintf( "%7.2f", $ref->{$k}) }; }
  
  return $ref;
}

$positive_note = 1;
__DATA__

# Calc ratios
#$Data{str} = '';
#while ( my($size, $ref) = each (%Ccd))
#{
#    # do whatever you want with $key and $value here ...
#    $ratio = sprintf("%7.4f",$ref->{x}/$ref->{y});
#    $Data{str} .= "\$Ccd{'$size'} = { 'x'=>$ref->{x}, 'y'=>$ref->{y}, 'ratio'=>$ratio };\n";
#}






