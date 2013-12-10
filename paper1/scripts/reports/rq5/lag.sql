# lag.rpt
select stage, extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit

# rp_lag.rpt
select extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit and stage = 'rp'

# mp_lag.rpt
select extract(epoch from t.date - c.committer_dt)/86400 as lag from git_commit_release r, git_refs_tags t, git_commit c  where t.path = r.release and r.commit = c.commit and stage = 'mp'



