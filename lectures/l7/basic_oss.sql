\set ECHO all

-- rank authors (normal commits)
select author, count(*) from git_commit where num_parent = 1 group by author order by count(*) desc limit 30;

-- rank integrators (merge commits)
select committer, count(*) from git_commit where num_parent > 1 group by committer order by count(*) desc limit 30;

-- author's area
select author, new_path, count(*) 
    from git_commit c, git_revision r 
    where c.commit = r.commit 
    group by author, new_path 
    order by count(*) desc;

-- author's area ordered by author, having made more than 100 commits
select author, new_path, count(*) 
    from git_commit c, git_revision r 
    where c.commit = r.commit 
    group by author, new_path 
    having count(*) > 100
    order by author;
