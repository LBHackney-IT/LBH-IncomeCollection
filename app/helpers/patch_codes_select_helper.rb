module PatchCodesSelectHelper
  def patch_codes
    {
        rent: [
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
            { name: 'Arrears East Patch 8', code: 'E08' },
            { name: 'Unassigned Patches', code: 'unassigned' }
        ],
        leasehold: [
            { name: 'Show All Patches', code: nil },
            { name: 'Service Charge Patch 1', code: 'SC1' },
            { name: 'Service Charge Patch 2', code: 'SC2' },
            { name: 'Service Charge Patch 3', code: 'SC3' },
            { name: 'Service Charge Patch 4', code: 'SC4' },
            { name: 'Service Charge Patch 5', code: 'SC5' },
            { name: 'Service Charge Patch 6', code: 'SC6' },
            { name: 'Service Charge Patch 7', code: 'SC7' },
            { name: 'Unassigned Patches', code: 'unassigned' }
        ]
    }
  end

  def patch_codes_options(selected: nil, service_area_type: :rent)
    options = patch_codes[service_area_type].map { |patch_code| [patch_code[:name], patch_code[:code]] }

    options_for_select(options, selected)
  end
end
