using Documenter, DocumenterCitations, Literate

using CairoMakie
CairoMakie.activate!(type = "svg")

bib_filepath = joinpath(dirname(@__FILE__), "blog.bib")
bib = CitationBibliography(bib_filepath, style=:authoryear)

#####
##### Build and deploy docs
#####

format = Documenter.HTML(
    collapselevel = 1,
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = MathJax3(),
    assets = String["assets/citations.css"]
)

pages = ["Home" => "index.md"]

makedocs(bib,
    sitename = "Jago Strong-Wright",
    authors = "Jago Strong-Wright",
    format = format,
    pages = pages,
    doctest = true,
    strict = true,
    clean = true,
    checkdocs = :exports
)

@info "Clean up temporary .jld2/.nc files created by doctests..."

"""
    recursive_find(directory, pattern)

Return list of filepaths within `directory` that contains the `pattern::Regex`.
"""
recursive_find(directory, pattern) =
    mapreduce(vcat, walkdir(directory)) do (root, dirs, files)
        joinpath.(root, filter(contains(pattern), files))
    end

files = []
for pattern in [r"\.jld2", r"\.nc"]
    global files = vcat(files, recursive_find(@__DIR__, pattern))
end

for file in files
    rm(file)
end

deploydocs(
    repo = "github.com/jagoosw/blog",
    forcepush = true,
    push_preview = true,
    devbranch = "main"
)
