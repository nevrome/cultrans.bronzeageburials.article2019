# create rendered article directory
mkdir rendered_article

# copy files to rendered_article directory
./_copy_files.sh

# do the actual rendering
./_render_article.sh
