#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  mut: string
  step3_mutate_output_pdb_path:
    type: File
  step4_pdb2gmx_config: string
  step4_pdb2gmx_output_gro_path: string
  step4_pdb2gmx_output_top_zip_path: string
  step5_editconf_config: string
  step5_editconf_output_gro_path: string
  step6_solvate_output_gro_path: string
  step6_solvate_output_top_zip_path: string
  step7_grompp_genion_config: string
  step7_grompp_genion_output_tpr_path: string
  step8_genion_config: string
  step8_genion_output_gro_path: string
  step8_genion_output_top_zip_path: string
  step9_grompp_min_config: string
  step9_grompp_min_output_tpr_path: string
  step10_mdrun_min_output_trr_path: string
  step10_mdrun_min_output_gro_path: string
  step10_mdrun_min_output_edr_path: string
  step10_mdrun_min_output_log_path: string
  step11_grompp_nvt_config: string
  step11_grompp_nvt_output_tpr_path: string
  step12_mdrun_nvt_output_trr_path: string
  step12_mdrun_nvt_output_gro_path: string
  step12_mdrun_nvt_output_edr_path: string
  step12_mdrun_nvt_output_log_path: string
  step12_mdrun_nvt_output_cpt_path: string
  step13_grompp_npt_config: string
  step13_grompp_npt_output_tpr_path: string
  step14_mdrun_npt_output_trr_path: string
  step14_mdrun_npt_output_gro_path: string
  step14_mdrun_npt_output_edr_path: string
  step14_mdrun_npt_output_log_path: string
  step14_mdrun_npt_output_cpt_path: string
  step15_grompp_md_config: string
  step15_grompp_md_output_tpr_path: string
  step16_mdrun_md_output_trr_path: string
  step16_mdrun_md_output_gro_path: string
  step16_mdrun_md_output_edr_path: string
  step16_mdrun_md_output_log_path: string
  step16_mdrun_md_output_cpt_path: string
  step17_gmx_image1_config: string
  step17_gmx_image1_output_traj_path: string
  step18_gmx_image2_config: string
  step18_gmx_image2_output_traj_path: string
  step19_gmx_trjconv_str_config: string
  step19_gmx_trjconv_str_output_str_path: string
  step20_gmx_energy_config: string
  step20_gmx_energy_output_xvg_path: string
  step21_gmx_rgyr_config: string
  step21_gmx_rgyr_output_xvg_path: string
  step22_rmsd_first_config: string
  step22_rmsd_first_output_cpptraj_path: string
  step23_rmsd_exp_config: string
  step23_rmsd_exp_output_cpptraj_path: string

outputs:
  dir:
    label: Whole workflow output
    type: Directory
    outputSource: step24_gather_outputs/project_work_dir

steps:
  step4_pdb2gmx:
    label: Pdb2gmx
    doc: |-
      Creates a compressed (ZIP) GROMACS topology (TOP and ITP files) from a given PDB file.
    run: biobb_adapters/biobb_adapters/cwl/biobb_md/pdb2gmx.cwl
    in:
      config: step4_pdb2gmx_config
      input_pdb_path: step3_mutate_output_pdb_path
      output_gro_path: step4_pdb2gmx_output_gro_path
      output_top_zip_path: step4_pdb2gmx_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path

  step5_editconf:
    label: Editconf
    doc: |-
      Creates a GROMACS structure file (GRO) adding the information of the solvent box to the input structure file.
    run: biobb_adapters/biobb_adapters/cwl/biobb_md/editconf.cwl
    in:
      config: step5_editconf_config
      input_gro_path: step4_pdb2gmx/output_gro_path
      output_gro_path: step5_editconf_output_gro_path
    out:
    - output_gro_path

  step6_solvate:
    label: Solvate
    doc: |-
      Creates a new compressed GROMACS topology file adding solvent molecules to a given input compressed GROMACS topology file.
    run: biobb_adapters/biobb_adapters/cwl/biobb_md/solvate.cwl
    in:
      input_solute_gro_path: step5_editconf/output_gro_path
      output_gro_path: step6_solvate_output_gro_path
      input_top_zip_path: step4_pdb2gmx/output_top_zip_path
      output_top_zip_path: step6_solvate_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path

  step7_grompp_genion:
    label: Grompp
    doc: |-
      Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/biobb_adapters/cwl/biobb_md/grompp.cwl
    in:
      config: step7_grompp_genion_config
      input_gro_path: step6_solvate/output_gro_path
      input_top_zip_path: step6_solvate/output_top_zip_path
      output_tpr_path: step7_grompp_genion_output_tpr_path
    out:
    - output_tpr_path

  step8_genion:
    label: Genion
    doc: |-
      Creates a new compressed GROMACS topology adding ions until reaching the desired concentration to the input compressed GROMACS topology. 
    run: biobb_adapters/biobb_adapters/cwl/biobb_md/genion.cwl
    in:
      config: step8_genion_config
      input_tpr_path: step7_grompp_genion/output_tpr_path
      output_gro_path: step8_genion_output_gro_path
      input_top_zip_path: step6_solvate/output_top_zip_path
      output_top_zip_path: step8_genion_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path


  step24_gather_outputs:
    label: Archiving outputs to be returned to user
    doc: >
      This uses the local md_gather.cwl workflow to gather all desired output files.
      A filter for missing files is applied (pickValue: all_non_null), which requires
      using a runner which is compliant with v1.2.0, or later, CWL standards.
    in:
      output_folder: mut
      external_files: 
        source:
          - step8_genion/output_top_zip_path
        linkMerge: merge_flattened
        pickValue: all_non_null
    run: md_gather.cwl
    out: [project_work_dir]

  
    







