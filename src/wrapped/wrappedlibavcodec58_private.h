#if !(defined(GO) && defined(GOM) && defined(GO2) && defined(DATA))
#error Meh...
#endif

GO(av_ac3_parse_header, iFpLpp)
GO(av_adts_header_parse, iFppp)
//GOM(av_alloc_vdpaucontext, pFEv)
GO(av_bsf_alloc, iFpp)  // AVBSFContext* contains AVClass* which might needs wrapping
GO(av_bsf_flush, vFp)   // AVBSFContext* contains AVClass* which might needs wrapping
GO(av_bsf_free, vFp)    // AVBSFContext* contains AVClass* which might needs wrapping
GO(av_bsf_get_by_name, pFp) // AVBSFContext* contains AVClass* which might needs wrapping
//GOM(av_bsf_get_class, pFEv)
GO(av_bsf_get_null_filter, iFp) // AVBSFContext* contains AVClass* which might needs wrapping
GO(av_bsf_init, iFp)    // AVBSFContext* contains AVClass* which might needs wrapping
//GOM(av_bsf_iterate, pFEp)
GO(av_bsf_list_alloc, pFv)
//GOM(av_bsf_list_append, iFEpp)
GO(av_bsf_list_append2, iFppp)
//GOM(av_bsf_list_finalize, iFEpp)
GO(av_bsf_list_free, vFp)
//GOM(av_bsf_list_parse_str, iFEpp)
GO(av_bsf_receive_packet, iFpp) // AVBSFContext* contains AVClass* which might needs wrapping
GO(av_bsf_send_packet, iFpp)    // AVBSFContext* contains AVClass* which might needs wrapping
//GOM(avcodec_align_dimensions, vFEppp)
GO(avcodec_align_dimensions2, vFpppp)
GO(avcodec_alloc_context3, pFp)
GO(avcodec_close, iFp)
GO(avcodec_configuration, pFv)
//GOM(avcodec_dct_alloc, pFEv)
//GOM(avcodec_dct_get_class, pFEv)
//GOM(avcodec_dct_init, iFEp)
GO(avcodec_decode_subtitle2, iFpppp) // AVCodecContext *, AVSubtitle *, AVPacket *
//GOM(avcodec_default_execute, iFEppppii)
//GOM(avcodec_default_execute2, iFEppppi)
GO(avcodec_default_get_buffer2, iFppi)
//GOM(avcodec_default_get_encode_buffer, iFEppi)
//GOM(avcodec_default_get_format, iFEpp)
GO(avcodec_descriptor_get, pFu)
GO(avcodec_descriptor_get_by_name, pFp)
GO(avcodec_descriptor_next, pFp)
//GOM(avcodec_encode_subtitle, iFEppip)
DATA(av_codec_ffversion, 8) // Warning: failed to confirm
GO(avcodec_fill_audio_frame, iFpiipii)
GO(avcodec_find_best_pix_fmt_of_list, iFpiip)
GO(avcodec_find_decoder, pFu)
GO(avcodec_find_decoder_by_name, pFp)
GO(avcodec_find_encoder, pFu)
GO(avcodec_find_encoder_by_name, pFp)
GO(avcodec_flush_buffers, vFp)
GO(avcodec_free_context, vFp)
//GOM(avcodec_get_class, pFEv)
//GOM(avcodec_get_hw_config, pFEpi)
//GOM(avcodec_get_hw_frames_parameters, iFEppip)
GO(avcodec_get_name, pFu)
//GOM(avcodec_get_subtitle_rect_class, pFEv)
//GOM(avcodec_get_supported_config, iFEppuupp)
GO(avcodec_get_type, iFu)
GO(av_codec_is_decoder, iFp)
GO(av_codec_is_encoder, iFp)
GO(avcodec_is_open, iFp)
GO(av_codec_iterate, pFp)
GO(avcodec_license, pFv)
GO(avcodec_open2, iFppp)
GO(avcodec_parameters_alloc, pFv)
GO(avcodec_parameters_copy, iFpp)
GO(avcodec_parameters_free, vFp)
GO(avcodec_parameters_from_context, iFpp)
GO(avcodec_parameters_to_context, iFpp)
GO(avcodec_pix_fmt_to_codec_tag, uFi)
GO(avcodec_profile_name, pFui)
GO(avcodec_receive_frame, iFpp)
GO(avcodec_receive_packet, iFpp)
GO(avcodec_send_frame, iFpp)
GO(avcodec_send_packet, iFpp)
//GOM(avcodec_string, vFEpipi)
GO(avcodec_version, uFv)
GO(av_cpb_properties_alloc, pFp)
//GO(av_d3d11va_alloc_context, 
GO(av_dct_calc, vFpp)
GO(av_dct_end, vFp)
GO(av_dct_init, pFiu)
GO(av_dirac_parse_sequence_header, iFppLp)
GO(av_dv_codec_profile, pFiii)
//GO(av_dv_codec_profile2, 
GO(av_dv_frame_profile, pFppu)
GO(av_fast_padded_malloc, vFppL)
GO(av_fast_padded_mallocz, vFppL)
GO(av_fft_calc, vFpp)
GO(av_fft_end, vFp)
GO(av_fft_init, pFii)
GO(av_fft_permute, vFpp)
//GOM(av_get_audio_frame_duration, iFEpi)
GO(av_get_audio_frame_duration2, iFpi)
GO(av_get_bits_per_sample, iFu)
GO(av_get_exact_bits_per_sample, iFu)
GO(av_get_pcm_codec, uFii)
//GOM(av_get_profile_name, pFEpi)
GO(av_grow_packet, iFpi)
GO(av_imdct_calc, vFppp)
GO(av_imdct_half, vFppp)
GO(av_init_packet, vFp)
GO(av_jni_get_java_vm, pFp)
GO(av_jni_set_java_vm, iFpp)
GO(av_mdct_calc, vFppp)
GO(av_mdct_end, vFp)
GO(av_mdct_init, pFiid)
GO(av_mediacodec_alloc_context, pFv)
//GOM(av_mediacodec_default_free, vFEp)
//GOM(av_mediacodec_default_init, iFEppp)
GO(av_mediacodec_release_buffer, iFpi)
GO(av_mediacodec_render_buffer_at_time, iFpI)
GO(av_new_packet, iFpi)
GO(av_packet_add_side_data, iFpupL)
GO(av_packet_alloc, pFv)
GO(av_packet_clone, pFp)
GO(av_packet_copy_props, iFpp)
GO(av_packet_free, vFp)
GO(av_packet_free_side_data, vFp)
GO(av_packet_from_data, iFppi)
GO(av_packet_get_side_data, pFpup)
GO(av_packet_make_refcounted, iFp)
GO(av_packet_make_writable, iFp)
GO(av_packet_move_ref, vFpp)
GO(av_packet_new_side_data, pFpuL)
GO(av_packet_pack_dictionary, pFpp)
GO(av_packet_ref, iFpp)
//GO(av_packet_rescale_ts, 
GO(av_packet_shrink_side_data, iFpuL)
GO(av_packet_side_data_add, pFppupLi)
GO(av_packet_side_data_free, vFpp)
GO(av_packet_side_data_get, pFpiu)
GO(av_packet_side_data_name, pFu)
GO(av_packet_side_data_new, pFppuLi)
GO(av_packet_side_data_remove, vFppu)
GO(av_packet_unpack_dictionary, iFpLp)
GO(av_packet_unref, vFp)
//GOM(av_parser_close, vFEp)
//GOM(av_parser_init, pFEi)
//GOM(av_parser_iterate, pFEp)
//GOM(av_parser_parse2, iFEpppppiIII)
//GO(avpriv_ac3_parse_header, 
//GO(avpriv_adts_header_parse, 
//GO(avpriv_codec_get_cap_skip_frame_fill_param, 
//GO(avpriv_dca_convert_bitstream, 
//GO(avpriv_dca_parse_core_frame_header, 
//GO(avpriv_elbg_do, 
//GO(avpriv_elbg_free, 
//GO(avpriv_exif_decode_ifd, 
//GO(avpriv_find_start_code, 
//GO(avpriv_fits_header_init, 
//GO(avpriv_fits_header_parse_line, 
//GO(avpriv_get_raw_pix_fmt_tags, 
//GO(avpriv_h264_has_num_reorder_frames, 
//GO(avpriv_mpeg4audio_get_config2, 
//GO(avpriv_mpegaudio_decode_header, 
//GO(avpriv_packet_list_free, 
//GO(avpriv_packet_list_get, 
//GO(avpriv_packet_list_put, 
//GO(avpriv_pix_fmt_find, 
//GO(avpriv_split_xiph_headers, 
//GO(avpriv_tak_parse_streaminfo, 
//GO(av_qsv_alloc_context, 
GO(av_rdft_calc, vFpp)
GO(av_rdft_end, vFp)
GO(av_rdft_init, pFiu)
GO(av_shrink_packet, vFpi)
GO(avsubtitle_free, vFp)
//GOM(av_vdpau_alloc_context, pFEv)
//GOM(av_vdpau_bind_context, iFEpupu)
//GOM(av_vdpau_get_surface_parameters, iFEpppp)
//GOM(av_vdpau_hwaccel_get_render2, pFEp)
//GOM(av_vdpau_hwaccel_set_render2, vFEpp)
GO(av_vorbis_parse_frame, iFppi)
GO(av_vorbis_parse_frame_flags, iFppip)
GO(av_vorbis_parse_free, vFp)
GO(av_vorbis_parse_init, pFpi)
GO(av_vorbis_parse_reset, vFp)
GO(av_xiphlacing, uFpu)
