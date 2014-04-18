require 'chassis'

class Post
  attr_accessor :id, :title, :text
end

repo = Chassis::Repo.default

puts repo.empty? Post #=> true

post = Post.new
post.title = 'Such Repos'
post.text = 'Very wow. Much design.'

repo.save post

puts post.id #=> 1

found_post = repo.find Post, post.id
found_post == post #=> true (no difference between objects in memory)

post.title = 'Such updates'
post.text = 'Very easy. Wow'

repo.save post

repo.find(Post, post.id).text #=> 'Very easy. Wow.'

class PostRepo
  extend Chassis::Repo::Delegation
end

post = PostRepo.find post.id
post.text #=> 'Very Easy. Wow'

PostRepo.all #=> [post]
# etc

PostRepo.delete post
PostRepo.empty? #=> true
