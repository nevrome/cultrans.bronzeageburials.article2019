# clone the repository to the book-output directory
git clone -b document \
  https://${GITHUB_PAT}@github.com/${TRAVIS_REPO_SLUG}.git \
  document_out
cd document_out
git rm -rf *
cp -r ../rendered_article/* ./
git add --all *
git commit -m "Update the rendered article"
git push -q origin document
