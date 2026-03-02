extends Area2D
signal hit

# 使用 @export 使得这个变量可以在编辑器（Inspector）中修改
# speed 决定了玩家移动的速度（像素/秒）
@export var speed = 400 
var screen_size # 游戏窗口的大小

# _ready() 在节点首次进入场景树时调用
func _ready() -> void:
	# 获取当前视口（游戏窗口）的大小
	screen_size = get_viewport_rect().size

# _process() 每一帧都会被调用
# delta 是上一帧到这一帧经过的时间（秒），用于保证移动速度在不同帧率下保持一致
func _process(delta):
	var velocity = Vector2.ZERO # 玩家的移动向量，初始为 (0, 0)
	
	# 检测玩家是否按下了对应的按键
	#Input.is_action_pressed() 返回 true 如果按键被按下
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# 如果有按键输入（velocity 长度大于 0）
	if velocity.length() > 0:
		# .normalized() 将向量归一化（长度变为1），防止斜向移动时速度变快（根号2倍）
		velocity = velocity.normalized() * speed
		# 播放动画
		$AnimatedSprite2D.play()
	else:
		# 没有移动时停止动画
		$AnimatedSprite2D.stop()
		
	# 根据移动方向选择播放哪个动画
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false # 不进行垂直翻转
		# 如果向左移动 (velocity.x < 0)，则水平翻转精灵
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		# 如果向下移动 (velocity.y > 0)，则垂直翻转精灵
		$AnimatedSprite2D.flip_v = velocity.y > 0
	
	# 更新玩家位置
	# 位置 = 当前位置 + (速度向量 * 时间间隔)
	#var old_position = position
	position += velocity * delta
	# clamp() 函数限制玩家的位置不能超出屏幕范围
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.length() > 0:
		print("Velocity: ", velocity, " Position: ", position)


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
