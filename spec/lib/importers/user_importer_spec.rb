require 'rails_helper'
require "#{Rails.root}/lib/importers/user_importer"

describe UserImporter do
  describe 'OAuth model association' do
    it 'should create new user based on OAuth data' do
      VCR.use_cassette 'user/user_id' do
        info = OpenStruct.new(name: 'Ragesock')
        credentials = OpenStruct.new(token: 'foo', secret: 'bar')
        hash = OpenStruct.new(uid: '14093230',
                              info: info,
                              credentials: credentials)
        auth = UserImporter.from_omniauth(hash)
        expect(auth.id).to eq(4_543_197)
      end
    end

    it 'should associate existing model with OAuth data' do
      existing = create(:user)
      info = OpenStruct.new(name: 'Ragesock')
      credentials = OpenStruct.new(token: 'foo', secret: 'bar')
      hash = OpenStruct.new(uid: '14093230',
                            info: info,
                            credentials: credentials)
      auth = UserImporter.from_omniauth(hash)
      expect(auth.id).to eq(existing.id)
    end
  end

  describe '.new_from_username' do
    it 'creates a new user' do
      VCR.use_cassette 'user/new_from_username' do
        username = 'Ragesoss'
        user = UserImporter.new_from_username(username)
        expect(user).to be_a(User)
        expect(user.username).to eq(username)
      end
    end

    it 'returns an existing user' do
      VCR.use_cassette 'user/new_from_username' do
        create(:user, id: 500, username: 'Ragesoss')
        username = 'Ragesoss'
        user = UserImporter.new_from_username(username)
        expect(user.id).to eq(500)
      end
    end

    it 'does not create a user if the username is not registered' do
      VCR.use_cassette 'user/new_from_username_nonexistent' do
        username = 'RagesossRagesossRagesoss'
        user = UserImporter.new_from_username(username)
        expect(user).to be_nil
      end
    end

    it 'creates a user with the correct username capitalization' do
      VCR.use_cassette 'user/new_from_username' do
        # Basic lower case letter at the beginning
        username = 'zimmer1048'
        user = UserImporter.new_from_username(username)
        expect(user.username).to eq('Zimmer1048')

        # Unicode lower case letter at the beginning
        username = 'áragetest'
        user = UserImporter.new_from_username(username)
        expect(user.username).to eq('Áragetest')
      end
    end
  end

  describe '.update_users' do
    it 'should update which users have completed training' do
      # Create a new user, who by default is assumed not to have been trained.
      ragesoss = create(:trained)
      expect(ragesoss.trained).to eq(false)

      # Update trained users to see that user has really been trained
      UserImporter.update_users
      ragesoss = User.all.first
      expect(ragesoss.trained).to eq(true)
    end

    it 'should handle exceptions for missing users' do
      user = [build(:user)]
      UserImporter.update_users(user)
    end
  end
end
