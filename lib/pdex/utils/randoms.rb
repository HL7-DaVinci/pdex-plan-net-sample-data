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
            case n % 4
            when 0
                return "newpt"
            when 1 
                return "nopt"
            when 2
                return "existptonly"
            else
                return "existptfam"
            end
        end
    end
end