; IDL Version 8.4, Mac OS X (darwin x86_64 m64)
; Journal File for schmit@west.lmsal.com
; Working directory: /links/sanhome/schmit/mosaic
; Date: Mon Aug 10 13:12:17 2015
 
ssw_jsoc_time2data,'2011-02-20','2011-02-21',index,data,ds='aia.lev1_euv_12s',wave='335',/local,/file
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; --------------------------------------------------------------------------
;| ssw_jsoc_time2query output: aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m] |
; --------------------------------------------------------------------------
; -------------------------
;| WAVELNTH added to query |
; -------------------------
; --------------------------
;| selecting segment> image |
; --------------------------
; -----------------------------------------------------------------------
;| /rs_list, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m][335]{image} |
; -----------------------------------------------------------------------
; ----------------------------------------------------------------------
;| /export, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m][335]{image} |
; ----------------------------------------------------------------------
; ---------------------
;| query -> files/urls |
; ---------------------
; ------------------------------------------------------------
;| None of the files for this time range/param set are online |
; ------------------------------------------------------------
help,index
help,data
help,index,/str
plot,index.datamean
; % Program caused arithmetic error: Floating illegal operand
plot,index.datamean,/yno
ssw_jsoc_time2data,’2011-02-20’,’2011-03-06’,index,ds=’aia.lev1_euv_12s’,$ 
; ---------------------------------------------
;| No data series supplied, guessing via WAVES |
; ---------------------------------------------
; ---------------------
;| DS=aia.lev1_euv_12s |
; ---------------------
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; ----------------------------------------------------------------
;| No output params specified so I won't waste your time and mine |
; ----------------------------------------------------------------
    waves=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’
; % Variable is undefined: B.
ssw_jsoc_time2data,’2011-02-20’,’2011-03-06’,index,ds=’aia.lev1_euv_12s’,waves=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’
; ---------------------------------------------
;| No data series supplied, guessing via WAVES |
; ---------------------------------------------
; ---------------------
;| DS=aia.lev1_euv_12s |
; ---------------------
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; ----------------------------------------------------------------
;| No output params specified so I won't waste your time and mine |
; ----------------------------------------------------------------
    waves=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’ssw_jsoc_time2data,’2011-02-20’,’2011-03-06’,index,ds=’aia.lev1_euv_12s’,wave=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’
; % Variable is undefined: B.
help
ssw_jsoc_time2data,’2011-02-20’,’2011-03-06’,index,ds=’aia.lev1_euv_12s’,wave=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’
; ---------------------------------------------
;| No data series supplied, guessing via WAVES |
; ---------------------------------------------
; ---------------------
;| DS=aia.lev1_euv_12s |
; ---------------------
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; ----------------------------------------------------------------
;| No output params specified so I won't waste your time and mine |
; ----------------------------------------------------------------
retall
ssw_jsoc_time2data,’2011-02-20’,’2011-03-06’,index,ds=’aia.lev1_euv_12s’,wave=’335’,key=’t_obs,wavelnth,datamean,exptime’,cadence=’1h’
; ---------------------------------------------
;| No data series supplied, guessing via WAVES |
; ---------------------------------------------
; ---------------------
;| DS=aia.lev1_euv_12s |
; ---------------------
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; ----------------------------------------------------------------
;| No output params specified so I won't waste your time and mine |
; ----------------------------------------------------------------
 ssw_jsoc_time2data,'2011-02-20','2011-02-21',index,data,ds='aia.lev1_euv_12s',wave='335',/local,cadence='1h'
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; -----------------------------------------------------------------------------
;| ssw_jsoc_time2query output: aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h] |
; -----------------------------------------------------------------------------
; -------------------------
;| WAVELNTH added to query |
; -------------------------
; --------------------------
;| selecting segment> image |
; --------------------------
; --------------------------------------------------------------------------
;| /rs_list, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h][335]{image} |
; --------------------------------------------------------------------------
; -------------------------------------------------------------------------
;| /export, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h][335]{image} |
; -------------------------------------------------------------------------
; ----------------------------------------------------------------
;| Spoofing jsoc NOTIFY email via freeland@lmsal.com              |
;| You may avoid this message by registering Your email@jsoc via: |
;| http://jsoc.stanford.edu/ajax/register_email.html              |
; ----------------------------------------------------------------
; -------------------
;| segment subselect |
; -------------------
; ----------------------------------------------------------------------------------
;| IDL> read_sdo,<filelist>,index [,data,llpx,llpy,nx,ny] [,/noshell] [/use_shared] |
; ----------------------------------------------------------------------------------
; ---------------------------------------------
;| Local read request but file(s) not found... |
; ---------------------------------------------
; ------------------------------------------------------------
;| None of the files for this time range/param set are online |
; ------------------------------------------------------------
help,index
ssw_jsoc_time2data,'2011-02-20','2011-02-21',index,data,ds='aia.lev1_euv_12s',wave='335',/local,cadence='1h',key='datamean'
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; -----------------------------------------------------------------------------
;| ssw_jsoc_time2query output: aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h] |
; -----------------------------------------------------------------------------
; -------------------------
;| WAVELNTH added to query |
; -------------------------
; --------------------------
;| selecting segment> image |
; --------------------------
; --------------------------------------------------------------------------
;| /rs_list, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h][335]{image} |
; --------------------------------------------------------------------------
; -------------------------------------------------------------------------
;| /export, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h][335]{image} |
; -------------------------------------------------------------------------
; ----------------------------------------------------------------
;| Spoofing jsoc NOTIFY email via freeland@lmsal.com              |
;| You may avoid this message by registering Your email@jsoc via: |
;| http://jsoc.stanford.edu/ajax/register_email.html              |
; ----------------------------------------------------------------
; -------------------
;| segment subselect |
; -------------------
; ----------------------------------------------------------------------------------
;| IDL> read_sdo,<filelist>,index [,data,llpx,llpy,nx,ny] [,/noshell] [/use_shared] |
; ----------------------------------------------------------------------------------
; ---------------------------------------------
;| Local read request but file(s) not found... |
; ---------------------------------------------
; ------------------------------------------------------------
;| None of the files for this time range/param set are online |
; ------------------------------------------------------------
help,index
help,index,/str
 ssw_jsoc_time2data,'2011-02-20','2011-02-21',index,data,ds='aia.lev1_euv_12s',/local,cadence='1h'
; -------------------------------------
;| /SERIES_STRUCT, ds=aia.lev1_euv_12s |
; -------------------------------------
; -----------------------------------------------------------------------------
;| ssw_jsoc_time2query output: aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h] |
; -----------------------------------------------------------------------------
; --------------------------
;| selecting segment> image |
; --------------------------
; ---------------------------------------------------------------------
;| /rs_list, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h]{image} |
; ---------------------------------------------------------------------
; --------------------------------------------------------------------
;| /export, ds=aia.lev1_euv_12s[2011-02-20T00:00:00Z/1440m@1h]{image} |
; --------------------------------------------------------------------
; ----------------------------------------------------------------
;| Spoofing jsoc NOTIFY email via freeland@lmsal.com              |
;| You may avoid this message by registering Your email@jsoc via: |
;| http://jsoc.stanford.edu/ajax/register_email.html              |
; ----------------------------------------------------------------
; -------------------
;| segment subselect |
; -------------------
; ----------------------------------------------------------------------------------
;| IDL> read_sdo,<filelist>,index [,data,llpx,llpy,nx,ny] [,/noshell] [/use_shared] |
; ----------------------------------------------------------------------------------
; ---------------------------------------------
;| Local read request but file(s) not found... |
; ---------------------------------------------
; ------------------------------------------------------------
;| None of the files for this time range/param set are online |
; ------------------------------------------------------------
help,index
help,index,/str
print,index.wave_str
;94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN
;131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN
;171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN
;193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN
;211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN
;304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN
;335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN
;94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN 94_THIN 131_THIN 171_THIN 193_THIN 211_THIN 304_THIN 335_THIN
