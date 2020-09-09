module PDEX
    module Randoms
        def category_type(name)
            if name.include?("HOSPITAL")
                HEALTHCARE_SERVICE_CATEGORY_TYPES[:hospital]
            elsif name.include?("CENTER") || name.include?("SURGERY")
                HEALTHCARE_SERVICE_CATEGORY_TYPES[:outpatient]
            else
                HEALTHCARE_SERVICE_CATEGORY_TYPES[:group]
            end
        end

        def accepting_patients_code(n)
            case n % 3
            when 0
                return "yes"
            when 1 
                return "no"
            when 2
                return "existing"
            else
                return "existingplusfamily"
            end
        end
    end
end