module PatchCodesSelectHelper
  def patch_codes
    [
      { name: 'Show All Patches', code: nil },
      { name: 'Arrears East Patch 1', code: 'E01' },
      { name: 'Arrears West Patch 1', code: 'W01' },
      { name: 'Arrears East Patch 2', code: 'E02' },
      { name: 'Arrears West Patch 2', code: 'W02' },
      { name: 'Arrears East Patch 3', code: 'E03' },
      { name: 'Arrears West Patch 3', code: 'W03' },
      { name: 'Arrears East Patch 4', code: 'E04' },
      { name: 'Arrears West Patch 4', code: 'W04' },
      { name: 'Arrears East Patch 5', code: 'E05' },
      { name: 'Arrears West Patch 5', code: 'W05' },
      { name: 'Arrears East Patch 6', code: 'E06' },
      { name: 'Arrears West Patch 6', code: 'W06' },
      { name: 'Arrears East Patch 7', code: 'E07' },
      { name: 'Arrears West Patch 7', code: 'W07' },
      { name: 'Arrears East Patch 8', code: 'E08' }
    ]
  end

  def patch_codes_options(selected: nil)
    options = patch_codes.map { |patch_code| [patch_code[:name], patch_code[:code]] }

    options_for_select(options, selected)
  end
end
