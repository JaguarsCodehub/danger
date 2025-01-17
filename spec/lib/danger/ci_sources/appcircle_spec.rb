require "danger/ci_source/appcircle"

RSpec.describe Danger::Appcircle do
  let(:valid_env) do
    {
      "AC_PULL_NUMBER" => "4",
      "AC_APPCIRCLE" => "true",
      "AC_GIT_URL" => "git@github.com:artsy/eigen"
    }
  end

  let(:invalid_env) do
    {
      "CIRCLE" => "true"
    }
  end

  let(:source) { described_class.new(valid_env) }

  describe ".validates_as_pr?" do
    it "validates when the required env variables are set" do
      expect(described_class.validates_as_pr?(valid_env)).to be true
    end

    it "does not validate when the required env variables are not set" do
      expect(described_class.validates_as_pr?(invalid_env)).to be false
    end

    it "does not validate when there isn't a PR" do
      valid_env["AC_PULL_NUMBER"] = nil
      expect(described_class.validates_as_pr?(valid_env)).to be false
    end
  end

  describe ".validates_as_ci?" do
    it "validates when the required env variables are set" do
      expect(described_class.validates_as_ci?(valid_env)).to be true
    end

    it "does not validate when the required env variables are not set" do
      expect(described_class.validates_as_ci?(invalid_env)).to be false
    end

    it "validates even when there is no PR" do
      valid_env["AC_PULL_NUMBER"] = nil
      expect(described_class.validates_as_ci?(valid_env)).to be true
    end
  end

  describe "#new" do
    it "sets the repo_slug" do
      expect(source.repo_slug).to eq("artsy/eigen")
    end

    it "sets the repo_slug from a repo with dots in it", host: :github do
      valid_env["AC_GIT_URL"] = "git@github.com:artsy/artsy.github.io"
      expect(source.repo_slug).to eq("artsy/artsy.github.io")
    end

    it "sets the repo_slug from a repo with two or more slashes in it", host: :github do
      valid_env["AC_GIT_URL"] = "git@github.com:artsy/mobile/ios/artsy.github.io"
      expect(source.repo_slug).to eq("artsy/mobile/ios/artsy.github.io")
    end

    it "sets the repo_slug from a repo with .git in it", host: :github do
      valid_env["AC_GIT_URL"] = "git@github.com:artsy/mobile/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/mobile/ios/artsy.github.io")
    end

    it "sets the repo_slug from a repo https url", host: :github do
      valid_env["AC_GIT_URL"] = "https://github.com/artsy/ios/artsy.github.io"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end
    
    it "sets the repo_slug from a repo https url with .git in it", host: :github do
      valid_env["AC_GIT_URL"] = "https://github.com/artsy/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end

    it "sets the repo_slug from a repo without scheme", host: :github do
      valid_env["AC_GIT_URL"] = "github.com/artsy/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end
    
    it "sets the repo_slug from a repo with .io instead of .com", host: :github do
      valid_env["AC_GIT_URL"] = "git@github.company.io:artsy/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end

    it "sets the repo_slug from an url that has an ssh scheme", host: :github do
      valid_env["AC_GIT_URL"] = "ssh://git@github.company.io/artsy/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end

    it "sets the repo_slug from an url that has a port in it and has ssh as a scheme", host: :github do
      valid_env["AC_GIT_URL"] = "ssh://git@github.company.io:22/artsy/ios/artsy.github.io.git"
      expect(source.repo_slug).to eq("artsy/ios/artsy.github.io")
    end

    it "sets the pull_request_id" do
      expect(source.pull_request_id).to eq("4")
    end

    it "sets the repo_url", host: :github do
      with_git_repo(origin: "git@github.com:artsy/eigen") do
        expect(source.repo_url).to eq("git@github.com:artsy/eigen")
      end
    end
  end

  describe "supported_request_sources" do
    it "supports GitHub" do
      expect(source.supported_request_sources).to include(Danger::RequestSources::GitHub)
    end
    it "supports GitLab" do
      expect(source.supported_request_sources).to include(Danger::RequestSources::GitLab)
    end
    it "supports BitBucket Cloud" do
      expect(source.supported_request_sources).to include(Danger::RequestSources::BitbucketCloud)
    end
    it "supports BitBucket Server" do
      expect(source.supported_request_sources).to include(Danger::RequestSources::BitbucketServer)
    end
  end
end
