
PRO aia_reg, input1, input2, oindex, odata, input_mode=input_mode, $
             index_ref=index_ref, $
             threeh=threeh, weekly=weekly, $
             no_mpo_update=no_mpo_update, force_mpo_update=force_mpo_update, $
             no_uncomp_delete=no_uncomp_delete, $
             nearest=nearest, interp=interp, cubic=cubic, normalize=normalize, $
             do_write_fits=do_write_fits, outdir=outdir, outfile=outfile, $
             use_dummy_fits=use_dummy_fits, verbose=verbose, run_time=run_time, $
             progver_main=progver_main, prognam_main=prognam_main, $
             qstop=qstop, _extra=_extra
;            threeh=threeh, weekly=weekly, $
;            no_mpo_update=no_mpo_update, force_mpo_update=force_mpo_update, $
;            no_uncomp_delete=no_uncomp_delete, $

;+
; NAME:
;   AIA_REG
; PURPOSE:
;   Perform image registration (rotation, translation, scaling) of Level 1 AIA images, and update
;   the header information.
; CATEGORY:
;   Image alignment
; SAMPLE CALLS:
;   Inputing infil (in this case iindex and idata are returned with 
;   IDL> AIA_PREP, infil, [0,1,2], oindex, odata
;   Inputing iindex and idata: 
;   IDL> AIA_PREP, iindex, idata, oindex, odata
; INPUTS:
;   There are 2 basic usages for inputing the image and header data into AIA_PREP:
;   Case 1: References FITS file name on disk:
;           input1 - String array list of AIA FITS files
;           input2 - List of indices of FITS files to read 
;   Case 2. References index structure and data array in memory
;           (index, data already read from FITS file using, for example, READ_SDO.PRO):
;           input1 - index structure
;           input2 - data array
; OUTPUTS (OPTIONAL):
;   oindex - The updated index structure of the input image
;   odata - Registered output image.
; KEYWORDS:
;   DS_MPO - JSOC MPO data series.  Default is: 'aia.master_pointing3h'
;   INDEX_REF - Reference index for alignment coordinates.
;               NOTA BENA - If INDEX_REF is not supplied, then all images will be
;               aligned to sun center.
;   DO_WRITE_FITS - If set, write the registered image and updated header structure to disk
;   NEAREST - If set, use nearest neighbor interpolatipon
;   INTERP - If set, use bilinear interpolation
;   CUBIC - If set, use cubic convolution interpolation ith the specified value (in the range [-1,0]
;           as the interpolation parameter.  Cubic interpolation with this parameter equal -0.5
;           is the default.
; TODO:
;   Calculate NAXIS1, NAXIS2 as follows:
;     naxis1,2 = gt_tagval(oindex0, /znaxis1,2, missing=gt_tagval(oindex0, /naxis1,2))
; HISTORY:
;   2013-07-22 - GLS, Alessandro Cilla - Corrected bugs associated with inputing files instead of
;                                        INDEX and DATA variables.
;   2019-04-10 - GLS - Added keyword 'ds_mpo' for specifying JSOC MPO data series.  Default is:
;                      'aia.master_pointing3h'
;   2022-06-14 - R. Timmons - Added print of which entry of MPO (by
;                T_Start) for Aug 2020- present time series offness in 'aia.master_pointing3h'
;-

; Define prognam, progver variables:
prognam = 'AIA_REG.PRO'
progver = 'V6.0' ; 2013-07-22 (GLS, Alessandro Cilla)

; Start the clock running:
t0 = systime(1)
t1 = t0	; Keep track of running time

if keyword_set(no_uncomp_delete) then uncomp_delete = 0 else uncomp_delete = 1

; Update all AIA header pointing tags using one of the the SDO MPO data series:

if input_mode eq 'file_list' then begin
   files = input1
;  mreadfits_header, files, iindex
   read_sdo, files, iindex
endif else begin
   iindex = input1
   idata = input2
endelse

stop
iindex_updated = aia2wcsmin(iindex, mpo_str=mpo_str, ds_mpo=ds_mpo, $
                            threeh=threeh, weekly=weekly, $
                            no_mpo_update=no_mpo_update, force_mpo_update=force_mpo_update, $
                            verbose=verbose, _extra=_extra)
;iindex_updated = aia2wcsmin(iindex, $
;                            mpo_str=mpo_str, verbose=verbose, _extra=_extra)
;iindex_updated = aia2wcsmin(iindex, no_mpo_update=no_mpo_update, $
;                            mpo_str=mpo_str, ds_mpo=ds_mpo, verbose=verbose, _extra=_extra)

; Now loop through images:

n_img = n_elements(input1)
for i=0, n_img-1 do begin  

   if input_mode eq 'file_list' then begin
      file0 = files[i]
      iindex0 = iindex_updated[i]
      read_sdo, file0, iindex0, idata0, uncomp_delete=uncomp_delete, $
                /mixed, /use_index
   endif else begin
      iindex0 = iindex_updated[i]
      idata0 = reform(idata[*,*,i])
   endelse

; If index_ref not passed then all images will be registered to the default L1p5 pointing,
; scaling, fov, and rotation values.  We must create a reference structure and populate
; the necessary wcs tags for L1p5 pointing, scaling, fov, and rotation:
   if ~exist(index_ref) then $
      index_ref = { naxis:2l, naxis1:4096l, naxis2:4096l, cdelt1:0.6d, cdelt2:0.6d, $
                    crpix1:2048.5d, crpix2:2048.5d, crota2:0.0d, pnt_ref:'l1p5' }

; Register single image using IDL function ROT.PRO:
   ssw_reg, iindex0, idata0, oindex1, odata1, wcs_ref=index_ref, $
            scale_ref=scale_ref, roll_ref=roll_ref, crpix1_ref, crpix2_ref, $
            interp=interp, cubic=cubic, x_off=x_off, y_off=y_off, $
            normalize=normalize, no_remap=no_remap, $
            _extra=_extra, qstop=qstop

; Update output header as needed:
   oindex2 = aia_fix_header(oindex1, odata1)

   update_history, oindex2, version=progver_main, caller=prognam_main
   update_history, oindex2, version=progver, caller=prognam

; If output index array or data cube is requested (params 3 and 4) then update these arrays:
   if n_params() ge 3 then begin
      if i eq 0 then oindex = oindex2 else oindex = concat_struct(oindex, oindex2)
   endif
   if n_params() ge 4 then begin
      if i eq 0 then begin
         data_type = size(odata1, /type)
         data_dim  = size(odata1, /dim)
         data_ndim = size(odata1, /n_dim)
         odata = make_array([data_dim[0], data_dim[1], n_img], type=data_type)
      endif
      odata[0,0,i] = odata1
   endif

; Optionally write out new FITS file:
   if keyword_set(do_write_fits) then begin
      if keyword_set(use_dummy_fits) then outfile = './dummy.fits'
      aia_write_fits, oindex2, odata1, outdir=outdir, outfile=outfile
   endif

endfor

if ( ~keyword_set(no_mpo_update) or keyword_set(force_mpo_update) ) then $
   print, ' AIA_REG: MPO updated using JSOC SDO master pointing series ' + $
          oindex.ds_mpo + ' with T_START ' + mpo_str.t_start + ' for image T_OBS ' + oindex2.t_obs else $
   print, " AIA_REG: MPO not updated because keyword 'NO_MPO_UPDATE' passed."

if keyword_set(qstop) then stop,' Stopping on request.'

end
