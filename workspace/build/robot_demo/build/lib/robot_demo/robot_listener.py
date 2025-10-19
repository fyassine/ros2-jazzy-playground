#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import PoseStamped

class RobotListener(Node):
    def __init__(self):
        super().__init__('robot_listener')
        self.subscription = self.create_subscription(
            PoseStamped,
            'robot_pose',
            self.listener_callback,
            10)
        self.get_logger().info('Robot Listener Started!')

    def listener_callback(self, msg):
        x = msg.pose.position.x
        y = msg.pose.position.y
        self.get_logger().info(f'Robot at: x={x:.2f}, y={y:.2f}')

def main(args=None):
    rclpy.init(args=args)
    node = RobotListener()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()