CREATE INDEX idx_dagi_id ON dagi (id);
-- Drop the existing index
DROP INDEX idx_dagi_id ON dagi;

-- Create the new index
CREATE INDEX idx_dagi_id ON dagi (id);


CREATE INDEX idx_dagi_bbr_id ON dagi_bbr (id);

select * from bolig_info;

CREATE INDEX idx_id ON housing_sample10 (id);
