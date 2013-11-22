\set ECHO all

select author, a.new_path, a.commits, a.churn, a.churn/r.churn as ownership_churn, a.commits/r.commits as ownership_commits from 

(select author, new_path, sum(add+remove) as churn, count(*) as commits from git_commit c, git_revision r where c.commit = r.commit and new_path ~ '\.[ch]\s*$' group by author, new_path) as a,

-- revisions per file
(select new_path, sum(add+remove) churn, count(*) commits from git_revision where new_path ~ '\.[ch]\s*$' group by new_path having sum(add+remove) > 0) as r

where a.new_path = r.new_path and a.churn/r.churn < 1 order by ownership_churn desc;

