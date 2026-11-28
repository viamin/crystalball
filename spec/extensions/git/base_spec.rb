# frozen_string_literal: true

require 'spec_helper'

describe Git::Base do
  let(:repo) { Git.open('.') }

  describe '#merge_base' do
    subject { repo.merge_base('HEAD^', 'HEAD').sha }

    let(:prehead) { repo.gcommit('HEAD^').sha }

    it { is_expected.to eq prehead }

    it 'passes revisions as individual arguments to ruby-git' do
      allow(repo.lib).to receive(:command).and_call_original

      expect(subject).to eq prehead
      expect(repo.lib).to have_received(:command).with('merge-base', 'HEAD^', 'HEAD')
    end
  end
end
